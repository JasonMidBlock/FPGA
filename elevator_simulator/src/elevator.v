// 中文：電梯模組，實現樓層移動、門操作和請求處理
// English: Elevator module, implements floor movement, door operations, and request handling
module elevator #(
    parameter FLOOR_MIN = 1,       // 中文：最低樓層 | English: Minimum floor
    parameter FLOOR_MAX = 8,       // 中文：最高樓層 | English: Maximum floor
    parameter TIME_MOVE = 5,       // 中文：樓層移動時間 | English: Floor movement time
    parameter TIME_DOOR_OPEN = 5,  // 中文：開門時間 | English: Door open time
    parameter TIME_DOOR_HOLD = 5,  // 中文：開門保持時間 | English: Door hold time
    parameter TIME_DOOR_CLOSE = 5  // 中文：關門時間 | English: Door close time
) (
    input wire clk,                // 中文：時鐘信號 | English: Clock signal
    input wire rst,                // 中文：重置信號 | English: Reset signal
    input wire [FLOOR_MAX-1:0] internal_req, // 中文：內部樓層請求 | English: Internal floor requests
    input wire [FLOOR_MAX-1:0] external_up_req, // 中文：外部上行請求 | English: External up requests
    input wire [FLOOR_MAX-1:0] external_down_req, // 中文：外部下行請求 | English: External down requests
    output reg [3:0] current_floor, // 中文：當前樓層 | English: Current floor
    output reg door_state,         // 中文：門狀態（1=開，0=關） | English: Door state (1=open, 0=closed)
    output reg [1:0] elevator_state // 中文：電梯狀態（00=靜止，01=上行，10=下行） | English: Elevator state (00=idle, 01=up, 10=down)
);

// 中文：狀態定義，使用參數表示 FSM 狀態
// English: State definitions, using parameters for FSM states
parameter IDLE = 3'b000,          // 中文：靜止 | English: Idle
          MOVE_UP = 3'b001,       // 中文：上行 | English: Up
          MOVE_DOWN = 3'b010,     // 中文：下行 | English: Down
          DOOR_OPENING = 3'b011,  // 中文：開門 | English: Door opening
          DOOR_HOLD = 3'b100,     // 中文：保持開門 | English: Door hold
          DOOR_CLOSING = 3'b101;  // 中文：關門 | English: Door closing

reg [2:0] state, next_state;   // 中文：當前和下一個狀態 | English: Current and next state
reg [FLOOR_MAX-1:0] req_queue; // 中文：請求隊列 | English: Request queue
reg [3:0] target_floor;        // 中文：目標樓層 | English: Target floor
reg [3:0] timer;               // 中文：計時器 | English: Timer
reg timer_en;                  // 中文：計時器啟用 | English: Timer enable
reg direction;                 // 中文：方向（1=上行，0=下行） | English: Direction (1=up, 0=down)

// 中文：邊緣檢測，檢測輸入請求的上升沿
// English: Edge detection, detect rising edges of input requests
reg [FLOOR_MAX-1:0] prev_internal_req, prev_external_up_req, prev_external_down_req;
wire [FLOOR_MAX-1:0] new_internal_req, new_external_up_req, new_external_down_req;
assign new_internal_req = internal_req & ~prev_internal_req;
assign new_external_up_req = external_up_req & ~prev_external_up_req;
assign new_external_down_req = external_down_req & ~prev_external_down_req;

// 中文：初始化與重置，設置初始狀態和清零
// English: Initialization and reset, set initial state and clear signals
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        current_floor <= FLOOR_MIN;
        door_state <= 0;
        elevator_state <= 2'b00;
        req_queue <= 0;
        timer <= 0;
        direction <= 1; // 中文：預設上行 | English: Default to up
        prev_internal_req <= 0;
        prev_external_up_req <= 0;
        prev_external_down_req <= 0;
    end else begin
        state <= next_state;
        prev_internal_req <= internal_req;
        prev_external_up_req <= external_up_req;
        prev_external_down_req <= external_down_req;
        if (timer_en && timer > 0)
            timer <= timer - 1;
    end
end

// 中文：請求輸入處理，合併新請求到隊列
// English: Request input handling, merge new requests into queue
always @(posedge clk) begin
    if (rst)
        req_queue <= 0;
    else
        req_queue <= req_queue | new_internal_req | new_external_up_req | new_external_down_req;
end

// 中文：FSM 狀態轉換，控制電梯行為
// English: FSM state transitions, control elevator behavior
always @(*) begin
    next_state = state;
    timer_en = 0;
    case (state)
        IDLE: begin
            door_state = 0;
            elevator_state = 2'b00;
            if (req_queue != 0) begin
                target_floor = current_floor;
                next_state = IDLE;
                if (direction) begin
                    // 中文：上行掃描，選擇高於當前樓層的最高請求
                    // English: Upward scan, select highest request above current floor
                    begin : up_loop
                        integer i;
                        for (i = FLOOR_MAX-1; i >= FLOOR_MIN-1; i = i - 1) begin
                            if (req_queue[i] && (i+1 > current_floor)) begin
                                target_floor = i + 1;
                                next_state = MOVE_UP;
                                disable up_loop;
                            end
                        end
                    end
                end else begin
                    // 中文：下行掃描，選擇低於當前樓層的最高請求
                    // English: Downward scan, select highest request below current floor
                    begin : down_loop
                        integer i;
                        for (i = FLOOR_MAX-1; i >= FLOOR_MIN-1; i = i - 1) begin
                            if (req_queue[i] && (i+1 < current_floor)) begin
                                target_floor = i + 1;
                                next_state = MOVE_DOWN;
                                disable down_loop;
                            end
                        end
                    end
                end
            end
        end
        MOVE_UP: begin
            elevator_state = 2'b01;
            timer_en = 1;
            if (timer == 0) begin
                current_floor = current_floor + 1;
                if (current_floor == target_floor) begin
                    req_queue[target_floor-1] = 0;
                    next_state = DOOR_OPENING;
                    timer = TIME_DOOR_OPEN;
                end else begin
                    timer = TIME_MOVE;
                end
            end
        end
        MOVE_DOWN: begin
            elevator_state = 2'b10;
            timer_en = 1;
            if (timer == 0) begin
                current_floor = current_floor - 1;
                if (current_floor == target_floor) begin
                    req_queue[target_floor-1] = 0;
                    next_state = DOOR_OPENING;
                    timer = TIME_DOOR_OPEN;
                end else begin
                    timer = TIME_MOVE;
                end
            end
        end
        DOOR_OPENING: begin
            elevator_state = 2'b00;
            timer_en = 1;
            if (timer == 0) begin
                door_state = 1;
                next_state = DOOR_HOLD;
                timer = TIME_DOOR_HOLD;
            end
        end
        DOOR_HOLD: begin
            elevator_state = 2'b00;
            timer_en = 1;
            if (timer == 0) begin
                next_state = DOOR_CLOSING;
                timer = TIME_DOOR_CLOSE;
            end
        end
        DOOR_CLOSING: begin
            elevator_state = 2'b00;
            timer_en = 1;
            if (timer == 0) begin
                door_state = 0;
                next_state = IDLE;
                // 中文：檢查是否需要切換方向
                // English: Check if direction needs to be switched
                if (direction && (current_floor == FLOOR_MAX || !(req_queue & ((1 << (FLOOR_MAX-1)) - (1 << current_floor)))))
                    direction = 0;
                else if (!direction && (current_floor == FLOOR_MIN || !(req_queue & ((1 << (current_floor-1)) - 1))))
                    direction = 1;
            end
        end
        default: next_state = IDLE;
    endcase
end

endmodule