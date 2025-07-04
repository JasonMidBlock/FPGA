// cpu_core.v
// Minimal RISC-V CPU core (stub for SoC integration)

module cpu_core(
    input wire clk,
    input wire rst_n,
    // Memory interface
    output reg [31:0] mem_addr,
    output reg [31:0] mem_wdata,
    output reg mem_write,
    input wire [31:0] mem_rdata,
    output reg mem_valid,
    input wire mem_ready
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_addr <= 0;
            mem_wdata <= 0;
            mem_write <= 0;
            mem_valid <= 0;
        end else begin
            // Example memory write on boot
            mem_addr <= 32'h00000000;
            mem_wdata <= 32'hABCD1234;
            mem_write <= 1;
            mem_valid <= 1;
        end
    end
endmodule
