// axi_lite_master.v
// Converts simple memory bus to AXI-Lite master interface

module axi_lite_master(
    input wire clk,
    input wire rst_n,

    // Simple memory bus interface
    input wire [31:0] mem_addr,
    input wire [31:0] mem_wdata,
    input wire mem_write,
    input wire mem_valid,
    output reg [31:0] mem_rdata,
    output reg mem_ready,

    // AXI-Lite master interface
    output reg [31:0] M_AXI_AWADDR,
    output reg        M_AXI_AWVALID,
    input  wire       M_AXI_AWREADY,

    output reg [31:0] M_AXI_WDATA,
    output reg [3:0]  M_AXI_WSTRB,
    output reg        M_AXI_WVALID,
    input  wire       M_AXI_WREADY,

    input  wire [1:0] M_AXI_BRESP,
    input  wire       M_AXI_BVALID,
    output reg        M_AXI_BREADY,

    output reg [31:0] M_AXI_ARADDR,
    output reg        M_AXI_ARVALID,
    input  wire       M_AXI_ARREADY,

    input  wire [31:0] M_AXI_RDATA,
    input  wire [1:0]  M_AXI_RRESP,
    input  wire        M_AXI_RVALID,
    output reg         M_AXI_RREADY
);
    localparam IDLE = 0, WRITE = 1, READ = 2;
    reg [1:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            mem_ready <= 0;
            M_AXI_AWVALID <= 0;
            M_AXI_WVALID <= 0;
            M_AXI_BREADY <= 0;
            M_AXI_ARVALID <= 0;
            M_AXI_RREADY <= 0;
        end else begin
            case (state)
                IDLE: begin
                    mem_ready <= 0;
                    if (mem_valid && mem_write) begin
                        // Write transaction
                        M_AXI_AWADDR <= mem_addr;
                        M_AXI_AWVALID <= 1;
                        M_AXI_WDATA <= mem_wdata;
                        M_AXI_WSTRB <= 4'b1111;
                        M_AXI_WVALID <= 1;
                        state <= WRITE;
                    end else if (mem_valid) begin
                        // Read transaction
                        M_AXI_ARADDR <= mem_addr;
                        M_AXI_ARVALID <= 1;
                        state <= READ;
                    end
                end
                WRITE: begin
                    if (M_AXI_AWREADY) M_AXI_AWVALID <= 0;
                    if (M_AXI_WREADY)  M_AXI_WVALID <= 0;
                    if (M_AXI_BVALID) begin
                        M_AXI_BREADY <= 1;
                        state <= IDLE;
                        mem_ready <= 1;
                    end else begin
                        M_AXI_BREADY <= 0;
                    end
                end
                READ: begin
                    if (M_AXI_ARREADY) M_AXI_ARVALID <= 0;
                    if (M_AXI_RVALID) begin
                        M_AXI_RREADY <= 1;
                        mem_rdata <= M_AXI_RDATA;
                        state <= IDLE;
                        mem_ready <= 1;
                    end else begin
                        M_AXI_RREADY <= 0;
                    end
                end
            endcase
        end
    end
endmodule
