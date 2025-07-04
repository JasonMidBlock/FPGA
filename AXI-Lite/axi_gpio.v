// axi_gpio.v
// Simple AXI-Lite GPIO Peripheral

module axi_gpio (
    input wire clk,
    input wire rst_n,

    // AXI Lite Slave Interface
    input wire [31:0] S_AXI_AWADDR,
    input wire        S_AXI_AWVALID,
    output wire       S_AXI_AWREADY,

    input wire [31:0] S_AXI_WDATA,
    input wire [3:0]  S_AXI_WSTRB,
    input wire        S_AXI_WVALID,
    output wire       S_AXI_WREADY,

    output wire [1:0] S_AXI_BRESP,
    output wire       S_AXI_BVALID,
    input wire        S_AXI_BREADY,

    input wire [31:0] S_AXI_ARADDR,
    input wire        S_AXI_ARVALID,
    output wire       S_AXI_ARREADY,

    output reg [31:0] S_AXI_RDATA,
    output wire [1:0] S_AXI_RRESP,
    output wire       S_AXI_RVALID,
    input wire        S_AXI_RREADY,

    output reg [7:0] gpio_out
);

    reg awready, wready, bvalid, arready, rvalid;

    assign S_AXI_AWREADY = awready;
    assign S_AXI_WREADY  = wready;
    assign S_AXI_BRESP   = 2'b00;
    assign S_AXI_BVALID  = bvalid;
    assign S_AXI_ARREADY = arready;
    assign S_AXI_RRESP   = 2'b00;
    assign S_AXI_RVALID  = rvalid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gpio_out <= 8'b0;
            awready <= 0; wready <= 0; bvalid <= 0;
            arready <= 0; rvalid <= 0; S_AXI_RDATA <= 0;
        end else begin
            awready <= S_AXI_AWVALID;
            wready <= S_AXI_WVALID;
            bvalid <= (S_AXI_AWVALID && S_AXI_WVALID);

            if (S_AXI_AWVALID && S_AXI_WVALID) begin
                if (S_AXI_AWADDR[3:0] == 4'h0) begin
                    gpio_out <= S_AXI_WDATA[7:0];
                end
            end

            arready <= S_AXI_ARVALID;
            rvalid <= S_AXI_ARVALID;
            if (S_AXI_ARVALID && S_AXI_ARADDR[3:0] == 4'h0) begin
                S_AXI_RDATA <= {24'b0, gpio_out};
            end
        end
    end
endmodule
