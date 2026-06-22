// =============================================================================
// Module      : tb_traffic_light_controller
// Project     : FPGA-Based Traffic Light Controller
// Description : Self-checking testbench. Tests:
//               1. Reset behavior
//               2. Full FSM cycle (S0 → S1 → S2 → S3 → S0)
//               3. Output correctness per state
//               4. Timer accuracy
//
// Simulation Tools : ModelSim, Vivado Simulator, EDA Playground, Icarus Verilog
// Run command (Icarus): iverilog -o sim tb_traffic_light_controller.v
//                        traffic_light_controller.v && vvp sim
// =============================================================================

`timescale 1ns / 1ps

module tb_traffic_light_controller;

    // =========================================================================
    // PARAMETERS (must match DUT parameters)
    // =========================================================================
    parameter GREEN_TIME  = 4'd10;
    parameter YELLOW_TIME = 4'd3;

    // =========================================================================
    // SIGNALS
    // =========================================================================
    reg  clk;
    reg  rst_n;
    wire ns_red, ns_yellow, ns_green;
    wire ew_red, ew_yellow, ew_green;

    // =========================================================================
    // DUT INSTANTIATION
    // =========================================================================
    traffic_light_controller #(
        .GREEN_TIME (GREEN_TIME),
        .YELLOW_TIME(YELLOW_TIME)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .ns_red    (ns_red),
        .ns_yellow (ns_yellow),
        .ns_green  (ns_green),
        .ew_red    (ew_red),
        .ew_yellow (ew_yellow),
        .ew_green  (ew_green)
    );

    // =========================================================================
    // CLOCK GENERATION — 10 ns period = 100 MHz
    // =========================================================================
    initial clk = 0;
    always #5 clk = ~clk;  // Toggle every 5 ns → 10 ns period

    // =========================================================================
    // TASK: Print current state of all outputs
    // =========================================================================
    task print_outputs;
        input [63:0] timestamp;
        begin
            $display("T=%0t | NS[R=%b Y=%b G=%b] | EW[R=%b Y=%b G=%b]",
                     timestamp,
                     ns_red, ns_yellow, ns_green,
                     ew_red, ew_yellow, ew_green);
        end
    endtask

    // =========================================================================
    // TASK: Check expected output and flag errors
    // =========================================================================
    integer error_count;

    task check_state;
        input [2:0] exp_ns;  // {ns_red, ns_yellow, ns_green}
        input [2:0] exp_ew;  // {ew_red, ew_yellow, ew_green}
        input [31:0] state_id;
        begin
            if ({ns_red, ns_yellow, ns_green} !== exp_ns ||
                {ew_red, ew_yellow, ew_green} !== exp_ew) begin
                $display("FAIL [S%0d] T=%0t | Got NS=%b EW=%b | Expected NS=%b EW=%b",
                         state_id, $time,
                         {ns_red, ns_yellow, ns_green},
                         {ew_red, ew_yellow, ew_green},
                         exp_ns, exp_ew);
                error_count = error_count + 1;
            end else begin
                $display("PASS [S%0d] T=%0t | NS=%b EW=%b ✓",
                         state_id, $time,
                         {ns_red, ns_yellow, ns_green},
                         {ew_red, ew_yellow, ew_green});
            end
        end
    endtask

    // =========================================================================
    // VCD DUMP — For waveform viewing in GTKWave or Vivado
    // =========================================================================
    initial begin
        $dumpfile("waveforms/traffic_light_sim.vcd");
        $dumpvars(0, tb_traffic_light_controller);
    end

    // =========================================================================
    // MAIN STIMULUS
    // =========================================================================
    initial begin
        error_count = 0;

        // -----------------------------------------------
        // Banner
        // -----------------------------------------------
        $display("============================================================");
        $display(" FPGA Traffic Light Controller — Testbench Simulation");
        $display("============================================================");
        $display(" GREEN_TIME  = %0d ticks", GREEN_TIME);
        $display(" YELLOW_TIME = %0d ticks", YELLOW_TIME);
        $display("------------------------------------------------------------");

        // -----------------------------------------------
        // TEST 1: Reset Behavior
        // -----------------------------------------------
        $display("\n--- TEST 1: Reset Assertion ---");
        rst_n = 0;         // Assert reset
        repeat(5) @(posedge clk);
        #1;
        $display("T=%0t | rst_n=0 | NS[R=%b Y=%b G=%b] | EW[R=%b Y=%b G=%b]",
                 $time, ns_red, ns_yellow, ns_green, ew_red, ew_yellow, ew_green);
        // After reset, expect S0: NS Green, EW Red → NS=001, EW=100
        check_state(3'b001, 3'b100, 0);

        // -----------------------------------------------
        // TEST 2: Release reset, observe S0 (NS Green)
        // -----------------------------------------------
        $display("\n--- TEST 2: S0 — NS Green, EW Red ---");
        rst_n = 1;
        repeat(2) @(posedge clk); #1;
        check_state(3'b001, 3'b100, 0);
        $display("  NS Green ON, EW Red ON — vehicles flow NS");

        // -----------------------------------------------
        // TEST 3: Wait through GREEN state → enter S1 (NS Yellow)
        // -----------------------------------------------
        $display("\n--- TEST 3: S1 — NS Yellow, EW Red ---");
        repeat(GREEN_TIME) @(posedge clk); #1;
        check_state(3'b010, 3'b100, 1);
        $display("  NS Yellow ON — warning, NS traffic should stop");

        // -----------------------------------------------
        // TEST 4: Wait through YELLOW → enter S2 (EW Green)
        // -----------------------------------------------
        $display("\n--- TEST 4: S2 — NS Red, EW Green ---");
        repeat(YELLOW_TIME) @(posedge clk); #1;
        check_state(3'b100, 3'b001, 2);
        $display("  EW Green ON — vehicles flow EW");

        // -----------------------------------------------
        // TEST 5: Wait through GREEN → enter S3 (EW Yellow)
        // -----------------------------------------------
        $display("\n--- TEST 5: S3 — NS Red, EW Yellow ---");
        repeat(GREEN_TIME) @(posedge clk); #1;
        check_state(3'b100, 3'b010, 3);
        $display("  EW Yellow ON — warning, EW traffic should stop");

        // -----------------------------------------------
        // TEST 6: Full cycle returns to S0 (NS Green)
        // -----------------------------------------------
        $display("\n--- TEST 6: Back to S0 — Cycle Complete ---");
        repeat(YELLOW_TIME) @(posedge clk); #1;
        check_state(3'b001, 3'b100, 0);
        $display("  Full cycle completed. FSM returned to S0 ✓");

        // -----------------------------------------------
        // TEST 7: Reset in mid-cycle
        // -----------------------------------------------
        $display("\n--- TEST 7: Mid-cycle Reset ---");
        repeat(5) @(posedge clk);    // advance a few ticks into S0
        rst_n = 0;
        @(posedge clk); #1;
        check_state(3'b001, 3'b100, 0);  // Must snap back to S0
        rst_n = 1;
        $display("  Mid-cycle reset OK — returned to S0 ✓");

        // -----------------------------------------------
        // TEST 8: Run one more full cycle to confirm stability
        // -----------------------------------------------
        $display("\n--- TEST 8: Second Full Cycle Verification ---");
        repeat(GREEN_TIME + YELLOW_TIME + GREEN_TIME + YELLOW_TIME + 2) @(posedge clk);
        #1;
        check_state(3'b001, 3'b100, 0);
        $display("  Second cycle stable ✓");

        // -----------------------------------------------
        // SUMMARY
        // -----------------------------------------------
        $display("\n============================================================");
        if (error_count == 0)
            $display(" ALL TESTS PASSED ✓ — No errors detected.");
        else
            $display(" SIMULATION FAILED — %0d error(s) found.", error_count);
        $display("============================================================\n");

        $finish;
    end

    // =========================================================================
    // MONITOR — Prints every rising edge for waveform log
    // =========================================================================
    initial begin
        $display("\n--- Continuous Output Monitor ---");
        $monitor("T=%6t | CLK=%b RST=%b | NS[R=%b Y=%b G=%b] | EW[R=%b Y=%b G=%b]",
                 $time, clk, rst_n,
                 ns_red, ns_yellow, ns_green,
                 ew_red, ew_yellow, ew_green);
    end

endmodule
