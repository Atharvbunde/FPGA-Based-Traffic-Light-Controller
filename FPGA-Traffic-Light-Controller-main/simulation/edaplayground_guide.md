# EDA Playground Simulation Guide
# Tool: https://edaplayground.com (Free, no installation needed)

## Steps:

1. Go to https://edaplayground.com
2. Sign up for a free account.

## Setup:
- Left panel (Design): Paste content of rtl/traffic_light_controller.v
- Right panel (Testbench): Paste content of tb/tb_traffic_light_controller.v

## Settings (top bar):
- Testbench + Design: ✓
- Language: Verilog/System Verilog
- Simulator: Icarus Verilog 12.0  (or Synopsys VCS if available)
- Check: "Open EPWave after run" ✓

## Click: ▶ Run

## Expected Console Output:
  ALL TESTS PASSED ✓ — No errors detected.

## Waveform (EPWave):
- Click "Open EPWave"
- Add signals: clk, rst_n, ns_red, ns_yellow, ns_green, ew_red, ew_yellow, ew_green
- Zoom to see full cycle
- Screenshot this waveform for GitHub

## Share:
- Click "Share" on EDA Playground
- Copy link — paste into your GitHub README
