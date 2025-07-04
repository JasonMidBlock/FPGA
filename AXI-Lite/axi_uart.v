module axi_uart #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 32
)(
    input  wire clk,
    input  wire rst_n,

    // AXI-Lite Slave Interface
    input  wire [ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input  wire                  S_AXI_AWVALID,
    output reg                   S_AXI_AWREADY,

    input  wire [DATA_WIDTH-1:0] S_AXI_WDATA,
    input  wire [3:0]            S_AXI_WSTRB,
    input  wire                  S_AXI_WVALID,
    output reg                   S_AXI_WREADY,

    output reg [1:0]             S_AXI_BRESP,
    output reg                   S_AXI_BVALID,
    input  wire                  S_AXI_BREADY,

    input  wire [ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input  wire                  S_AXI_ARVALID,
    output reg                   S_AXI_ARREADY,

    output reg [DATA_WIDTH-1:0]  S_AXI_RDATA,
    output reg [1:0]             S_AXI_RRESP,
    output reg                   S_AXI_RVALID,
    input  wire                  S_AXI_RREADY,

    // UART TX output (模擬用)
    output reg [7:0] uart_tx_data,
    output reg       uart_tx_valid
);

    localparam ADDR_TXDATA = 4'h0;
    localparam ADDR_STATUS = 4'h4;

    reg tx_ready;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            S_AXI_AWREADY <= 0;
            S_AXI_WREADY  <= 0;
            S_AXI_BVALID  <= 0;
            S_AXI_BRESP   <= 2'b00;

            S_AXI_ARREADY <= 0;
            S_AXI_RVALID  <= 0;
            S_AXI_RRESP   <= 2'b00;
            S_AXI_RDATA   <= 32'b0;

            uart_tx_valid <= 0;
            tx_ready <= 1;
        end else begin
            // Write
            S_AXI_AWREADY <= ~S_AXI_AWREADY & S_AXI_AWVALID;
            S_AXI_WREADY  <= ~S_AXI_WREADY & S_AXI_WVALID;

            if (S_AXI_AWREADY & S_AXI_AWVALID & S_AXI_WREADY & S_AXI_WVALID) begin
                if (S_AXI_AWADDR[3:0] == ADDR_TXDATA && tx_ready) begin
                    uart_tx_data <= S_AXI_WDATA[7:0];
                    uart_tx_valid <= 1;
                    tx_ready <= 0;
                end
                S_AXI_BVALID <= 1;
            end

            if (uart_tx_valid)
                uart_tx_valid <= 0;

            if (S_AXI_BVALID && S_AXI_BREADY) begin
                S_AXI_BVALID <= 0;
                tx_ready <= 1; // 模擬立即完成
            end

            // Read
            S_AXI_ARREADY <= ~S_AXI_ARREADY & S_AXI_ARVALID;
            if (S_AXI_ARREADY && S_AXI_ARVALID) begin
                S_AXI_RVALID <= 1;
                case (S_AXI_ARADDR[3:0])
                    ADDR_STATUS: S_AXI_RDATA <= {31'b0, tx_ready}; // [0] = tx_ready
                    default:     S_AXI_RDATA <= 32'hDEAD_BEEF;
                endcase
            end else if (S_AXI_RVALID && S_AXI_RREADY) begin
                S_AXI_RVALID <= 0;
            end
        end
    end
endmodule
