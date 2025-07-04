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

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        WRITE = 2'b01,
        READ = 2'b10
    } state_t;

    state_t state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = IDLE;
        case (state)
            IDLE: begin
                if (wr_en)
                    next_state = WRITE;
                else if (rd_en)
                    next_state = READ;
            end
            WRITE: next_state = IDLE;
            READ : next_state = IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_addr  <= 0;
            mem_dout  <= 0;
            mem_wr_en <= 0;
            rd_data   <= 0;
            ready     <= 0;
        end else begin
            ready     <= 0;
            mem_wr_en <= 0;

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
