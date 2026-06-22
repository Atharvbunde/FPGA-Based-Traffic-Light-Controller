// =============================================================================
// Module      : clock_divider
// Project     : FPGA-Based Traffic Light Controller
// Description : Divides a fast system clock (e.g., 50 MHz) down to 1 Hz
//               for human-visible traffic light timing on FPGA boards.
//
// Formula     : clk_out toggles every (CLK_FREQ / (2 * OUT_FREQ)) counts
//               For 50 MHz → 1 Hz: counter limit = 25_000_000
//
// NOTE: For pure simulation, you do NOT need this module.
//       Use it only when targeting a real FPGA board.
// =============================================================================

`timescale 1ns / 1ps

module clock_divider #(
    parameter CLK_FREQ  = 50_000_000,  // Input clock frequency in Hz (50 MHz default)
    parameter OUT_FREQ  = 1            // Desired output frequency in Hz (1 Hz = 1 tick/sec)
) (
    input  wire clk_in,   // Fast system clock from FPGA oscillator
    input  wire rst_n,    // Active-low reset
    output reg  clk_out   // Divided slow clock output
);

    // Counter width — must be wide enough to hold CLK_FREQ/2
    localparam COUNT_MAX = (CLK_FREQ / (2 * OUT_FREQ)) - 1;
    localparam CNT_WIDTH = 26; // 2^26 = 67M, enough for 50MHz→1Hz

    reg [CNT_WIDTH-1:0] count;

    always @(posedge clk_in) begin
        if (!rst_n) begin
            count   <= 0;
            clk_out <= 1'b0;
        end else if (count == COUNT_MAX) begin
            count   <= 0;
            clk_out <= ~clk_out;  // Toggle output → divide by 2×COUNT_MAX
        end else begin
            count <= count + 1;
        end
    end

endmodule
