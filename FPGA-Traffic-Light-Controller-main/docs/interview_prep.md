# Interview Preparation — FPGA Traffic Light Controller

## 10 Interview Questions & Answers

---

### Q1. Explain your project.

**Answer:**

"I designed and implemented an FPGA-based traffic light controller using Verilog. The core of the project is a 4-state Moore Finite State Machine that controls traffic signals for a two-road intersection — North-South and East-West directions.

The FSM cycles through four states:
- S0: North-South Green, East-West Red (traffic flows NS)
- S1: North-South Yellow, East-West Red (NS warning)
- S2: North-South Red, East-West Green (traffic flows EW)
- S3: North-South Red, East-West Yellow (EW warning)

State transitions are timer-driven — the FSM stays in each state for a configurable number of clock cycles (GREEN_TIME and YELLOW_TIME parameters). I used a clock divider to scale a 50 MHz FPGA clock down to 1 Hz for real-time visible operation.

I wrote a complete self-checking testbench that verifies all state transitions, reset behavior, and output correctness. The simulation produces a VCD waveform viewable in GTKWave. For FPGA deployment, I mapped the six output signals to LEDs on a Basys3 board using an XDC constraints file.

This project demonstrates FSM design, sequential and combinational logic, clock division, synthesis, and industry-standard verification practices."

---

### Q2. What is a Finite State Machine? Why did you use it here?

**Answer:**

A Finite State Machine (FSM) is a computational model with a fixed number of states, where the system is always in exactly one state, and transitions between states are determined by inputs or conditions.

I used an FSM for this project because:
1. Traffic control has a **finite, well-defined set of states** (NS Green, NS Yellow, EW Green, EW Yellow)
2. Transitions are **deterministic** — triggered by timer expiry, not random events
3. FSMs map naturally to **hardware registers** — the state register is just a flip-flop
4. Moore FSMs give **glitch-free outputs** since outputs depend only on state, not inputs

The two types are Moore (outputs depend on state only) and Mealy (outputs depend on state + inputs). I chose **Moore FSM** for cleaner, safer output behavior.

---

### Q3. What is the difference between Moore and Mealy FSMs?

**Answer:**

| Property           | Moore FSM              | Mealy FSM                      |
|--------------------|------------------------|-------------------------------|
| Output depends on  | State only             | State + current inputs         |
| Output timing      | Synchronous (1 cycle lag) | Asynchronous (immediate)    |
| States needed      | More states            | Fewer states possible         |
| Glitch risk        | Lower                  | Higher (combinational path)   |
| Example            | Traffic light          | Sequence detector              |

I used **Moore FSM** — outputs (traffic lights) depend only on the current state, not any input. This makes the output stable and glitch-free.

---

### Q4. What is a clock divider and why did you need it?

**Answer:**

A clock divider takes a high-frequency clock and produces a lower-frequency output by counting edges. My FPGA board has a 50 MHz oscillator — that's 50 million ticks per second. If I drove the FSM at 50 MHz, each state would last 20 nanoseconds — invisible to the human eye.

I designed a clock divider that counts 25,000,000 rising edges and then toggles the output, producing a 1 Hz clock (1 tick per second). This gives human-visible 10-second green phases and 3-second yellow phases on the LEDs.

The formula is: `counter_limit = CLK_FREQ / (2 × OUT_FREQ) = 50,000,000 / 2 = 25,000,000`

---

### Q5. What is the purpose of the testbench? How did you verify your design?

**Answer:**

A testbench is a non-synthesizable Verilog module that simulates the DUT (Design Under Test) by:
1. Generating stimulus (clock, reset, inputs)
2. Observing outputs
3. Comparing outputs to expected values

My testbench:
- Generates a 100 MHz clock (`always #5 clk = ~clk`)
- Asserts reset and checks FSM starts at S0
- Waits the exact number of ticks per state and verifies outputs
- Uses a `check_state` task for self-checking (prints PASS/FAIL)
- Tests mid-cycle reset recovery
- Dumps a VCD waveform file for visual inspection in GTKWave

---

### Q6. What is an XDC file? What does it do?

**Answer:**

An XDC (Xilinx Design Constraints) file tells Vivado how to map logical ports in your Verilog to physical pins on the FPGA chip. Without it, Vivado doesn't know which physical pin drives which LED or receives the clock.

In my XDC file, I specified:
- `clk` maps to pin W5 (100 MHz oscillator on Basys3)
- `rst_n` maps to pin U18 (center button)
- `ns_green` maps to pin U19 (LED 2), etc.

I also set `IOSTANDARD LVCMOS33` — this tells the FPGA to use 3.3V logic levels for I/O banks.

---

### Q7. What is synthesis vs implementation in FPGA flow?

**Answer:**

**Synthesis** converts Verilog RTL (behavioral description) into a netlist of logic gates (AND, OR, flip-flops) — it's technology-independent. The tool checks for:
- Syntax errors
- Latches (unintended state-holding elements)
- Timing/combinational issues

**Implementation** maps the generic netlist onto the specific FPGA's resources (LUTs, flip-flops, routing fabric). It has three sub-steps:
1. **Placement** — assigns logic to physical LUT/FF locations
2. **Routing** — connects placed elements with FPGA routing tracks
3. **Bitstream generation** — creates the binary file to program the FPGA

---

### Q8. What are LUTs and FFs in an FPGA?

**Answer:**

**LUT (Look-Up Table):** A small memory that implements combinational logic. A 6-input LUT can implement any Boolean function of 6 variables. Vivado synthesizes combinational logic (case statements, if/else) into LUTs.

**FF (Flip-Flop):** A 1-bit memory element that stores state on a clock edge. Vivado synthesizes `always @(posedge clk)` blocks into flip-flops.

In my project:
- The FSM state register (2 bits) maps to 2 flip-flops
- The timer counter (28 bits) maps to 28 flip-flops
- The output logic (case statement) maps to a few LUTs

---

### Q9. What is setup time and hold time? Why do they matter in your project?

**Answer:**

**Setup time (Tsu):** Data must be stable at a flip-flop's input a minimum time *before* the clock edge arrives.

**Hold time (Th):** Data must remain stable for a minimum time *after* the clock edge.

If setup time is violated, the flip-flop may sample incorrect data (metastability). If hold time is violated, the flip-flop may lose its value.

In Vivado, after implementation, the **Timing Summary** shows:
- **WNS (Worst Negative Slack):** must be ≥ 0 (positive = timing met)
- **TNS:** Total negative slack — must be 0 for a working design

My design at 1 Hz is extremely relaxed and easily meets timing. At 50 MHz it still easily closes timing since the logic is simple (a few LUTs deep).

---

### Q10. What are the future improvements you would add to this project?

**Answer:**

1. **Pedestrian Button** — Add an input that extends the current red phase to give pedestrians time to cross. Requires inserting a new WAIT state in the FSM.

2. **Emergency Vehicle Preemption** — A sensor input that immediately forces all directions to Red, then gives green to the emergency vehicle's direction. Requires a priority interrupt state.

3. **Adaptive Timing** — Connect IR/ultrasonic sensors to measure vehicle queue length. Extend green time if queue is long. Requires a variable timer instead of fixed GREEN_TIME.

4. **7-Segment Display** — Show a countdown timer so drivers know how many seconds remain. Requires a BCD decoder and 7-segment driver module.

5. **UART Monitor** — Send state transitions over UART to a laptop for remote monitoring and logging — useful in smart city infrastructure.

---

## Bonus Conceptual Questions

- **What is metastability?** → When a FF input violates setup/hold time, output may oscillate before settling — solved by synchronizers.
- **What is a critical path?** → The longest combinational delay chain in the design — determines max clock frequency.
- **What is RTL?** → Register Transfer Level — describes data flow between registers using clock-synchronized operations.
- **Why use parameters?** → Makes the design reusable and configurable without code changes (e.g., different timing for day vs night).
