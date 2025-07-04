module mem_controller #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  wr_en,
    input  wire                  rd_en,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output reg  [DATA_WIDTH-1:0] rd_data,
    output reg                   ready,

    output reg  [ADDR_WIDTH-1:0] mem_addr,
    output reg  [DATA_WIDTH-1:0] mem_dout,
    input  wire [DATA_WIDTH-1:0] mem_din,
    output reg                   mem_wr_en
);

    // 狀態編碼
    reg [1:0] state, next_state;
    localparam IDLE  = 2'b00;
    localparam WRITE = 2'b01;
    localparam READ  = 2'b10;

    // 狀態切換
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // 下一狀態邏輯
    always @(*) begin
        case (state)
            IDLE: begin
                if (wr_en)
                    next_state = WRITE;
                else if (rd_en)
                    next_state = READ;
                else
                    next_state = IDLE;
            end
            WRITE: next_state = IDLE;
            READ : next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // 輸出與控制邏輯
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_addr  <= 0;
            mem_dout  <= 0;
            mem_wr_en <= 0;
            rd_data   <= 0;
            ready     <= 0;
        end else begin
            mem_wr_en <= 0;
            ready     <= 0;

            case (state)
                WRITE: begin
                    mem_addr  <= addr;
                    mem_dout  <= wr_data;
                    mem_wr_en <= 1;
                    ready     <= 1;
                end
                READ: begin
                    mem_addr <= addr;
                    rd_data  <= mem_din;
                    ready    <= 1;
                end
            endcase
        end
    end

endmodule
