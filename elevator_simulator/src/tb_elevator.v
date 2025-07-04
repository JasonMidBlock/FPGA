// 電梯系統測試平台，模擬電梯的請求處理和狀態變化
// Elevator system testbench, simulates request handling and state transitions
module elevator_tb;
    // 參數定義，設置樓層範圍和時鐘週期
    // Parameter definitions for floor range and clock period
    parameter FLOOR_MIN = 1;        // 最低樓層 | Minimum floor
    parameter FLOOR_MAX = 8;        // 最高樓層 | Maximum floor
    parameter CLK_PERIOD = 10;      // 時鐘週期（單位時間） | Clock period (time units)

    // 信號宣告，定義輸入和輸出信號
    // Signal declarations for inputs and outputs
    reg clk, rst;                  // 時鐘和重置信號 | Clock and reset signals
    reg [FLOOR_MAX-1:0] internal_req, external_up_req, external_down_req; // 內部、外部上行和下行請求 | Internal, external up, and down requests
    wire [3:0] current_floor;      // 當前樓層 | Current floor
    wire door_state;               // 門狀態（1=開，0=關） | Door state (1=open, 0=closed)
    wire [1:0] elevator_state;     // 電梯狀態（00=靜止，01=上行，10=下行） | Elevator state (00=idle, 01=up, 10=down)

    // 實例化電梯模組，連接輸入和輸出
    // Instantiate the elevator module, connect inputs and outputs
    elevator #(
        .FLOOR_MIN(FLOOR_MIN),
        .FLOOR_MAX(FLOOR_MAX)
    ) uut (
        .clk(clk),
        .rst(rst),
        .internal_req(internal_req),
        .external_up_req(external_up_req),
        .external_down_req(external_down_req),
        .current_floor(current_floor),
        .door_state(door_state),
        .elevator_state(elevator_state)
    );

    // 時鐘生成，產生週期為 CLK_PERIOD 的時鐘信號
    // Clock generation, produces a clock signal with period CLK_PERIOD
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // 狀態描述函數，將電梯狀態轉換為文字描述
    // State description function, converts elevator state to text
    function [31:0] elevator_state_desc;
        input [1:0] state;
        begin
            case (state)
                2'b00: elevator_state_desc = "Idle";    // 靜止 | Idle
                2'b01: elevator_state_desc = "Up";      // 上行 | Up
                2'b10: elevator_state_desc = "Down";    // 下行 | Down
                default: elevator_state_desc = "Unknown"; // 未知 | Unknown
            endcase
        end
    endfunction

    // 測試流程，模擬多種請求場景並輸出狀態
    // Test procedure, simulates various request scenarios and outputs states
    initial begin
        // 初始化，重置系統並清除所有請求
        // Initialization, reset the system and clear all requests
        rst = 1;
        internal_req = 0;
        external_up_req = 0;
        external_down_req = 0;
        #20 rst = 0;
        $display("Time=%0t: Reset completed", $time); // 重置完成 | Reset completed

        // 持續監控電梯狀態，顯示時間、樓層、門狀態等
        // Continuously monitor elevator state, display time, floor, door state, etc.
        $monitor("Time=%0t | Floor=%0d | Door=%s | State=%s | Target Floor=%0d | Req Queue=%b",
                 $time, current_floor, door_state ? "Open" : "Closed",
                 elevator_state_desc(elevator_state), uut.target_floor, uut.req_queue);

        // 測試案例 1 - 內部請求 4 樓，驗證基本移動
        // Test Case 1 - Internal request for floor 4, verify basic movement
        #10 internal_req[3] = 1; // 請求 4 樓 | Request floor 4
        $display("Time=%0t: Test Case 1 - Internal request for floor 4", $time);
        #100 internal_req[3] = 0;

        // 測試案例 2 - 外部上行請求 6 樓，內部請求 2 樓，測試相反方向請求
        // Test Case 2 - External up request for floor 6, internal request for floor 2, test opposite direction requests
        #50 external_up_req[5] = 1; // 請求 6 樓上行 | Request floor 6 up
        $display("Time=%0t: Test Case 2 - External up request for floor 6", $time);
        #10 internal_req[1] = 1;    // 請求 2 樓 | Request floor 2
        $display("Time=%0t: Test Case 2 - Internal request for floor 2", $time);
        #200 external_up_req[5] = 0;
        internal_req[1] = 0;

        // 測試案例 3 - 外部下行請求 3 樓，驗證下行處理
        // Test Case 3 - External down request for floor 3, verify downward movement
        #50 external_down_req[2] = 1; // 請求 3 樓下行 | Request floor 3 down
        $display("Time=%0t: Test Case 3 - External down request for floor 3", $time);
        #150 external_down_req[2] = 0;

        // 測試案例 4 - 多樓層連續內部請求（1 樓、5 樓、8 樓），驗證 FIFO 處理
        // Test Case 4 - Multiple internal requests (floors 1, 5, 8), verify FIFO handling
        #50 internal_req[0] = 1; // 請求 1 樓 | Request floor 1
        $display("Time=%0t: Test Case 4 - Internal request for floor 1", $time);
        #10 internal_req[4] = 1; // 請求 5 樓 | Request floor 5
        $display("Time=%0t: Test Case 4 - Internal request for floor 5", $time);
        #10 internal_req[7] = 1; // 請求 8 樓 | Request floor 8
        $display("Time=%0t: Test Case 4 - Internal request for floor 8", $time);
        #200 internal_req[0] = 0;
        internal_req[4] = 0;
        internal_req[7] = 0;

        // 測試案例 5 - 外部上行和下行請求同時發生（7 樓上行、3 樓下行），驗證方向優先
        // Test Case 5 - Simultaneous external up and down requests (floor 7 up, floor 3 down), verify direction priority
        #50 external_up_req[6] = 1; // 請求 7 樓上行 | Request floor 7 up
        external_down_req[2] = 1;   // 請求 3 樓下行 | Request floor 3 down
        $display("Time=%0t: Test Case 5 - External up request for floor 7, down request for floor 3", $time);
        #200 external_up_req[6] = 0;
        external_down_req[2] = 0;

        // 測試案例 6 - 邊界測試（1 樓外部下行、8 樓外部上行），驗證邊界行為
        // Test Case 6 - Boundary test (floor 1 down, floor 8 up), verify boundary behavior
        #50 external_down_req[0] = 1; // 請求 1 樓下行 | Request floor 1 down
        $display("Time=%0t: Test Case 6 - External down request for floor 1", $time);
        #10 external_up_req[7] = 1;   // 請求 8 樓上行 | Request floor 8 up
        $display("Time=%0t: Test Case 6 - External up request for floor 8", $time);
        #200 external_down_req[0] = 0;
        external_up_req[7] = 0;

        // 測試案例 7 - 快速連續請求（ 2 樓內部、4 樓上行、6 樓下行 ），驗證隊列更新
        // Test Case 7 - Rapid consecutive requests (floor 2 internal, floor 4 up, floor 6 down), verify queue updates
        #50 internal_req[1] = 1;      // 請求 2 樓 | Request floor 2
        $display("Time=%0t: Test Case 7 - Internal request for floor 2", $time);
        #10 external_up_req[3] = 1;   // 請求 4 樓上行 | Request floor 4 up
        $display("Time=%0t: Test Case 7 - External up request for floor 4", $time);
        #10 external_down_req[5] = 1; // 請求 6 樓下行 | Request floor 6 down
        $display("Time=%0t: Test Case 7 - External down request for floor 6", $time);
        #200 internal_req[1] = 0;
        external_up_req[3] = 0;
        external_down_req[5] = 0;

        // 結束模擬，輸出完成提示
        // End simulation, output completion message
        #200 $display("Time=%0t: Simulation finished", $time);
        $finish;
    end

    // 波形儲存，生成 VCD 檔案用於波形分析
    // Waveform storage, generate VCD file for waveform analysis
    initial begin
        $dumpfile("elevator.vcd");
        $dumpvars(0, elevator_tb);
    end
endmodule