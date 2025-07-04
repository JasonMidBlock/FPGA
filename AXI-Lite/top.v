// top.v
// SoC top module connecting CPU, AXI-Lite master, and peripherals

module top (
    input wire clk,
    input wire rst_n,
    output wire [7:0] gpio,
    output wire uart_tx,
    input  wire uart_rx
);

    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire mem_write;
    wire [31:0] mem_rdata;
    wire mem_valid;
    wire mem_ready;

    wire [31:0] M_AXI_AWADDR, M_AXI_WDATA, M_AXI_ARADDR, M_AXI_RDATA;
    wire [3:0]  M_AXI_WSTRB;
    wire        M_AXI_AWVALID, M_AXI_AWREADY;
    wire        M_AXI_WVALID,  M_AXI_WREADY;
    wire [1:0]  M_AXI_BRESP;   wire M_AXI_BVALID, M_AXI_BREADY;
    wire        M_AXI_ARVALID, M_AXI_ARREADY;
    wire [1:0]  M_AXI_RRESP;   wire M_AXI_RVALID, M_AXI_RREADY;

    cpu_core u_cpu (
        .clk(clk), .rst_n(rst_n),
        .mem_addr(mem_addr), .mem_wdata(mem_wdata), .mem_write(mem_write),
        .mem_rdata(mem_rdata), .mem_valid(mem_valid), .mem_ready(mem_ready)
    );

    axi_lite_master u_master (
        .clk(clk), .rst_n(rst_n),
        .mem_addr(mem_addr), .mem_wdata(mem_wdata), .mem_write(mem_write),
        .mem_valid(mem_valid), .mem_rdata(mem_rdata), .mem_ready(mem_ready),
        .M_AXI_AWADDR(M_AXI_AWADDR), .M_AXI_AWVALID(M_AXI_AWVALID), .M_AXI_AWREADY(M_AXI_AWREADY),
        .M_AXI_WDATA(M_AXI_WDATA),   .M_AXI_WSTRB(M_AXI_WSTRB),     .M_AXI_WVALID(M_AXI_WVALID), .M_AXI_WREADY(M_AXI_WREADY),
        .M_AXI_BRESP(M_AXI_BRESP),   .M_AXI_BVALID(M_AXI_BVALID),   .M_AXI_BREADY(M_AXI_BREADY),
        .M_AXI_ARADDR(M_AXI_ARADDR), .M_AXI_ARVALID(M_AXI_ARVALID), .M_AXI_ARREADY(M_AXI_ARREADY),
        .M_AXI_RDATA(M_AXI_RDATA),   .M_AXI_RRESP(M_AXI_RRESP),     .M_AXI_RVALID(M_AXI_RVALID), .M_AXI_RREADY(M_AXI_RREADY)
    );

    axi_lite_interconnect u_interconnect (
        .clk(clk), .rst_n(rst_n),
        .M_AXI_AWADDR(M_AXI_AWADDR), .M_AXI_AWVALID(M_AXI_AWVALID), .M_AXI_AWREADY(M_AXI_AWREADY),
        .M_AXI_WDATA(M_AXI_WDATA),   .M_AXI_WSTRB(M_AXI_WSTRB),     .M_AXI_WVALID(M_AXI_WVALID), .M_AXI_WREADY(M_AXI_WREADY),
        .M_AXI_BRESP(M_AXI_BRESP),   .M_AXI_BVALID(M_AXI_BVALID),   .M_AXI_BREADY(M_AXI_BREADY),
        .M_AXI_ARADDR(M_AXI_ARADDR), .M_AXI_ARVALID(M_AXI_ARVALID), .M_AXI_ARREADY(M_AXI_ARREADY),
        .M_AXI_RDATA(M_AXI_RDATA),   .M_AXI_RRESP(M_AXI_RRESP),     .M_AXI_RVALID(M_AXI_RVALID), .M_AXI_RREADY(M_AXI_RREADY)
        // Connect slaves internally
    );

endmodule
