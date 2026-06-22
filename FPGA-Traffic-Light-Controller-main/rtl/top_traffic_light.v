// =============================================================================
// Module      : top_traffic_light
// Project     : FPGA-Based Traffic Light Controller
// Description : Top-level wrapper. Instantiates clock_divider and
//               traffic_light_controller. Use this module for FPGA synthesis.
//               For simulation use traffic_light_controller directly.
// =============================================================================

`timescale 1ns / 1ps

module top_traffic_light (
    input  wire clk,        // 50 MHz board oscillator
    input  wire rst_n,      // Push button reset (active low)
    output wire ns_red,
    output wire ns_yellow,
    output wire ns_green,
    output wire ew_red,
    output wire ew_yellow,
    output wire ew_green
);

    wire slow_clk;  // 1 Hz clock after division

    // ------------------------------------------------------------------
    // Clock Divider: 50 MHz → 1 Hz (1 second per tick)
    // ------------------------------------------------------------------
    clock_divider #(
        .CLK_FREQ(50_000_000),
        .OUT_FREQ(1)
    ) u_clk_div (
        .clk_in  (clk),
        .rst_n   (rst_n),
        .clk_out (slow_clk)
    );

    // ------------------------------------------------------------------
    // Traffic Light FSM Controller
    // GREEN_TIME=10 ticks × 1 sec = 10 seconds green
    // YELLOW_TIME=3 ticks × 1 sec = 3 seconds yellow
    // Adjust parameters as needed
    // ------------------------------------------------------------------
    traffic_light_controller #(
        .GREEN_TIME (4'd10),
        .YELLOW_TIME(4'd3)
    ) u_tlc (
        .clk       (slow_clk),
        .rst_n     (rst_n),
        .ns_red    (ns_red),
        .ns_yellow (ns_yellow),
        .ns_green  (ns_green),
        .ew_red    (ew_red),
        .ew_yellow (ew_yellow),
        .ew_green  (ew_green)
    );

endmodule
