# FPGA-Based Traffic Light Controller — Project Report

**Course:** VLSI Design / Digital Systems  
**Project Title:** FPGA-Based Traffic Light Controller  
**Language:** Verilog  
**Tools:** Icarus Verilog / ModelSim / Xilinx Vivado  

---

## 1. Project Objective

Design and implement a Finite State Machine (FSM)-based traffic light controller using Verilog, simulate it using a testbench, and optionally deploy it on an FPGA board. The controller manages traffic signals for a two-road intersection (North-South and East-West).

---

## 2. Problem Statement

Traffic intersections require precise, timed control of signals to ensure safe and efficient flow of vehicles. A digital FSM is ideal for this because:
- Traffic states are well-defined and finite
- State transitions are deterministic (timer-based)
- The design maps directly to hardware (FPGA/ASIC)

---

## 3. FSM Design

### States

| State | NS Signal | EW Signal | Duration     |
|-------|-----------|-----------|--------------|
| S0    | Green     | Red       | GREEN_TIME   |
| S1    | Yellow    | Red       | YELLOW_TIME  |
| S2    | Red       | Green     | GREEN_TIME   |
| S3    | Red       | Yellow    | YELLOW_TIME  |

### State Transition Diagram (Text)

```
       ┌─────────────────────────────────────────┐
       │                                         │
       ▼                                         │
  ┌─────────┐   timer_done   ┌─────────┐         │
  │   S0    │─────────────►  │   S1    │         │
  │ NS Green│                │NS Yellow│         │
  │ EW Red  │                │ EW Red  │         │
  └─────────┘                └─────────┘         │
                                  │               │
                            timer_done            │
                                  │               │
                                  ▼               │
                             ┌─────────┐          │
                             │   S2    │          │
                             │ NS Red  │          │
                             │EW Green │          │
                             └─────────┘          │
                                  │               │
                            timer_done            │
                                  │               │
                                  ▼               │
                             ┌─────────┐          │
                             │   S3    │──────────┘
                             │ NS Red  │  timer_done
                             │EW Yellow│
                             └─────────┘
```

### Output Table

| State | ns_red | ns_yellow | ns_green | ew_red | ew_yellow | ew_green |
|-------|--------|-----------|----------|--------|-----------|----------|
| S0    | 0      | 0         | 1        | 1      | 0         | 0        |
| S1    | 0      | 1         | 0        | 1      | 0         | 0        |
| S2    | 1      | 0         | 0        | 0      | 0         | 1        |
| S3    | 1      | 0         | 0        | 0      | 1         | 0        |

---

## 4. Architecture

```
      clk ──────────────────────────────────────────┐
                                                     │
      rst_n ────────────────────────────────────┐    │
                                                │    │
                                         ┌──────┴────┴──────┐
                                         │   clock_divider   │
                                         │  (50MHz → 1Hz)   │
                                         └────────┬──────────┘
                                                  │ slow_clk
                                         ┌────────▼──────────┐
                                         │   FSM Controller  │
                                         │  ┌─────────────┐  │
                                         │  │ State Reg   │  │
                                         │  │ (S0-S3)     │  │
                                         │  └──────┬──────┘  │
                                         │  ┌──────▼──────┐  │
                                         │  │ Timer/Count │  │
                                         │  └──────┬──────┘  │
                                         │  ┌──────▼──────┐  │
                                         │  │ Output Logic│  │
                                         │  └──────┬──────┘  │
                                         └─────────┼─────────┘
                                                   │
                    ┌──────────────────────────────▼──────────────────────┐
                    │ ns_red  ns_yellow  ns_green  ew_red  ew_yellow  ew_green │
                    └─────────────────────────────────────────────────────┘
                         │       │          │        │        │          │
                        LED0    LED1       LED2    LED3     LED4       LED5
```

---

## 5. Module Descriptions

### `traffic_light_controller.v`
- **Type:** Moore FSM
- **Inputs:** clk, rst_n
- **Outputs:** ns_red, ns_yellow, ns_green, ew_red, ew_yellow, ew_green
- **Internal:** state register, timer counter, next-state logic

### `clock_divider.v`
- Divides 50 MHz → 1 Hz using a counter
- Used only for FPGA board implementation

### `top_traffic_light.v`
- Top-level wrapper for FPGA synthesis
- Connects clock divider and FSM

---

## 6. Testbench Explanation

The testbench `tb_traffic_light_controller.v` performs:

1. **Reset Test** — Verifies FSM starts at S0 on reset
2. **S0 Test** — Checks NS Green, EW Red after reset release
3. **S1 Test** — Waits GREEN_TIME ticks, checks NS Yellow
4. **S2 Test** — Waits YELLOW_TIME ticks, checks EW Green
5. **S3 Test** — Waits GREEN_TIME ticks, checks EW Yellow
6. **Cycle Test** — Verifies return to S0 after full cycle
7. **Mid-cycle Reset** — Resets mid-way, checks snap to S0
8. **Second cycle** — Confirms stable repeated behavior

Output: `ALL TESTS PASSED ✓` if FSM is correct.

---

## 7. Waveform Analysis

Expected waveform sequence for one full cycle (GREEN_TIME=10, YELLOW_TIME=3):

```
Time     | 0   | 10  | 13  | 23  | 26  |
State    | S0  | S1  | S2  | S3  | S0  |
ns_green | ███████|    |    |    |████
ns_yellow|    |███|    |    |    |
ns_red   |    |    |████████|███|
ew_red   |███████████|    |    |
ew_green |    |    |████████|    |
ew_yellow|    |    |    |███|    |
```

---

## 8. FPGA Implementation Steps

1. **Create Vivado Project** → RTL Project, no sources initially
2. **Add Sources** → Add all 3 `.v` files from `/rtl`
3. **Add Constraints** → Add `traffic_light_basys3.xdc`
4. **Run Synthesis** → Check for errors in synthesis report
5. **Run Implementation** → Check timing summary (Wns should be > 0)
6. **Generate Bitstream** → Program → Hardware Manager → Auto Connect → Program
7. **Observe LEDs** → 6 LEDs cycle through traffic states visually

---

## 9. Conclusion

This project demonstrates:
- **FSM design** — Clean state machine for real-world control
- **Sequential logic** — Timer-driven state transitions
- **Combinational output** — Moore FSM output logic
- **Testbench verification** — Automated self-checking simulation
- **FPGA implementation** — Hardware LED output with clock divider
- **Industry relevance** — Foundation for embedded controllers, traffic management systems

---

## 10. Future Improvements

- Add pedestrian button input (interrupt-based state transition)
- Emergency vehicle preemption (override FSM to give green to emergency direction)
- Sensor-adaptive timing (extend green if traffic density is high)
- 7-segment countdown display showing seconds remaining
- UART-based remote monitoring
