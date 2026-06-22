// =============================================================================
// Module      : traffic_light_controller
// Project     : FPGA-Based Traffic Light Controller
// Author      : VLSI Student Project
// Description : 4-state FSM-based traffic light controller for North-South
//               and East-West directions with clock divider and timer logic.
//
// States:
//   S0 : NS Green,  EW Red    (NS traffic flows)
//   S1 : NS Yellow, EW Red    (NS warning)
//   S2 : NS Red,    EW Green  (EW traffic flows)
//   S3 : NS Red,    EW Yellow (EW warning)
//
// Outputs (active HIGH):
//   ns_red, ns_yellow, ns_green  — North-South lights
//   ew_red, ew_yellow, ew_green  — East-West lights
// =============================================================================

`timescale 1ns / 1ps

module traffic_light_controller (
    input  wire clk,        // System clock
    input  wire rst_n,      // Active-low synchronous reset
    output reg  ns_red,     // North-South Red
    output reg  ns_yellow,  // North-South Yellow
    output reg  ns_green,   // North-South Green
    output reg  ew_red,     // East-West Red
    output reg  ew_yellow,  // East-West Yellow
    output reg  ew_green    // East-West Green
);

    // =========================================================================
    // PARAMETERS — Adjust these for simulation vs real FPGA timing
    // =========================================================================
    // For simulation: small counts (easy to verify in waveform)
    // For FPGA 50 MHz clock: GREEN=2500000 (~50ms), YELLOW=1000000 (~20ms)
    // For real-world: GREEN=2500000000 (~50s), YELLOW=1000000000 (~20s)
    parameter GREEN_TIME  = 4'd10;   // 10 clock ticks (sim) / change for FPGA
    parameter YELLOW_TIME = 4'd3;    // 3 clock ticks  (sim)

    // =========================================================================
    // STATE ENCODING — One-hot or binary
    // =========================================================================
    localparam [1:0]
        S0 = 2'b00,  // NS Green,  EW Red
        S1 = 2'b01,  // NS Yellow, EW Red
        S2 = 2'b10,  // NS Red,    EW Green
        S3 = 2'b11;  // NS Red,    EW Yellow

    // =========================================================================
    // INTERNAL SIGNALS
    // =========================================================================
    reg [1:0]  state, next_state;          // Current and next FSM state
    reg [27:0] timer;                      // Timer counter for state duration
    wire       timer_done;                 // Timer expiry signal

    // =========================================================================
    // CLOCK DIVIDER (optional — used when driving from fast FPGA clock)
    // For simulation we use the raw clock directly; for FPGA instantiate
    // clock_divider module and feed its output here instead.
    // =========================================================================

    // =========================================================================
    // TIMER LOGIC — counts clock ticks per state
    // =========================================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            timer <= 28'd0;
        end else if (timer_done) begin
            timer <= 28'd0;         // Reset when limit reached
        end else begin
            timer <= timer + 1'b1;
        end
    end

    // Timer done: depends on current state's duration
    assign timer_done = ((state == S0 || state == S2) && (timer == GREEN_TIME  - 1)) ||
                        ((state == S1 || state == S3) && (timer == YELLOW_TIME - 1));

    // =========================================================================
    // FSM — State Register (Sequential)
    // =========================================================================
    always @(posedge clk) begin
        if (!rst_n)
            state <= S0;
        else if (timer_done)
            state <= next_state;
    end

    // =========================================================================
    // FSM — Next-State Logic (Combinational)
    // =========================================================================
    always @(*) begin
        case (state)
            S0: next_state = S1;  // NS Green  → NS Yellow
            S1: next_state = S2;  // NS Yellow → EW Green
            S2: next_state = S3;  // EW Green  → EW Yellow
            S3: next_state = S0;  // EW Yellow → NS Green (cycle repeat)
            default: next_state = S0;
        endcase
    end

    // =========================================================================
    // OUTPUT LOGIC (Combinational — Moore FSM outputs depend only on state)
    // =========================================================================
    always @(*) begin
        // Default all outputs LOW (safe state)
        {ns_red, ns_yellow, ns_green} = 3'b100; // Default: NS Red
        {ew_red, ew_yellow, ew_green} = 3'b100; // Default: EW Red

        case (state)
            S0: begin // NS Green, EW Red
                ns_red = 1'b0; ns_yellow = 1'b0; ns_green = 1'b1;
                ew_red = 1'b1; ew_yellow = 1'b0; ew_green = 1'b0;
            end
            S1: begin // NS Yellow, EW Red
                ns_red = 1'b0; ns_yellow = 1'b1; ns_green = 1'b0;
                ew_red = 1'b1; ew_yellow = 1'b0; ew_green = 1'b0;
            end
            S2: begin // NS Red, EW Green
                ns_red = 1'b1; ns_yellow = 1'b0; ns_green = 1'b0;
                ew_red = 1'b0; ew_yellow = 1'b0; ew_green = 1'b1;
            end
            S3: begin // NS Red, EW Yellow
                ns_red = 1'b1; ns_yellow = 1'b0; ns_green = 1'b0;
                ew_red = 1'b0; ew_yellow = 1'b1; ew_green = 1'b0;
            end
            default: begin
                ns_red = 1'b1; ns_yellow = 1'b0; ns_green = 1'b0;
                ew_red = 1'b1; ew_yellow = 1'b0; ew_green = 1'b0;
            end
        endcase
    end

endmodule
