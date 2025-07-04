module axi_timer #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 32
)(
    input  wire clk,
    input  wire rst_n,

    // AXI-Lite Interface
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
    input  wire                  S_AXI_RREADY
);

    localparam ADDR_TIMER = 4'h0;
    localparam ADDR_CTRL  = 4'h4;

    reg [31:0] timer;
    reg        reset_timer;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            timer <= 0;
        else if (reset_timer)
            timer <= 0;
        else
            timer <= timer + 1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            S_AXI_AWREADY <= 0;
            S_AXI_WREADY  <= 0;
            S_AXI_BVALID  <= 0;
            S_AXI_ARREADY <= 0;
            S_AXI_RVALID  <= 0;
            reset_timer   <= 0;
        end else begin
            // Write
            S_AXI_AWREADY <= ~S_AXI_AWREADY & S_AXI_AWVALID;
            S_AXI_WREADY  <= ~S_AXI_WREADY & S_AXI_WVALID;

            if (S_AXI_AWREADY & S_AXI_AWVALID & S_AXI_WREADY & S_AXI_WVALID) begin
                if (S_AXI_AWADDR[3:0] == ADDR_CTRL && S_AXI_WDATA[0]) begin
                    reset_timer <= 1;
                end
                S_AXI_BVALID <= 1;
            end else begin
                reset_timer <= 0;
            end

            if (S_AXI_BVALID && S_AXI_BREADY)
                S_AXI_BVALID <= 0;

            // Read
            S_AXI_ARREADY <= ~S_AXI_ARREADY & S_AXI_ARVALID;
            if (S_AXI_ARREADY && S_AXI_ARVALID) begin
                S_AXI_RVALID <= 1;
                case (S_AXI_ARADDR[3:0])
                    ADDR_TIMER: S_AXI_RDATA <= timer;
                    default:    S_AXI_RDATA <= 32'hBEEF_F00D;
                endcase
            end else if (S_AXI_RVALID && S_AXI_RREADY) begin
                S_AXI_RVALID <= 0;
            end
        end
    end
endmodule
