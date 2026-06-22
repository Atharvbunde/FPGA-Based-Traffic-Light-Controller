## =============================================================================
## Constraints File : traffic_light_basys3.xdc
## Board            : Digilent Basys3 (Artix-7 35T)
## Project          : FPGA-Based Traffic Light Controller
## =============================================================================
## PIN MAPPING:
##   System Clock  → W5 (100 MHz on-board oscillator)
##   Reset Button  → U18 (Center button BTNC)
##
##   Traffic Light LEDs:
##   NS Red        → U16 (LD0)
##   NS Yellow     → E19 (LD1)
##   NS Green      → U19 (LD2)
##   EW Red        → V19 (LD3)
##   EW Yellow     → W18 (LD4)
##   EW Green      → U15 (LD5)
## =============================================================================

## ── Clock ───────────────────────────────────────────────────────────────────
set_property PACKAGE_PIN W5   [get_ports clk]
set_property IOSTANDARD  LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## ── Reset Button (active low — press to reset) ──────────────────────────────
set_property PACKAGE_PIN U18  [get_ports rst_n]
set_property IOSTANDARD  LVCMOS33 [get_ports rst_n]

## ── North-South Lights (LEDs 0-2) ───────────────────────────────────────────
set_property PACKAGE_PIN U16  [get_ports ns_red]
set_property IOSTANDARD  LVCMOS33 [get_ports ns_red]

set_property PACKAGE_PIN E19  [get_ports ns_yellow]
set_property IOSTANDARD  LVCMOS33 [get_ports ns_yellow]

set_property PACKAGE_PIN U19  [get_ports ns_green]
set_property IOSTANDARD  LVCMOS33 [get_ports ns_green]

## ── East-West Lights (LEDs 3-5) ─────────────────────────────────────────────
set_property PACKAGE_PIN V19  [get_ports ew_red]
set_property IOSTANDARD  LVCMOS33 [get_ports ew_red]

set_property PACKAGE_PIN W18  [get_ports ew_yellow]
set_property IOSTANDARD  LVCMOS33 [get_ports ew_yellow]

set_property PACKAGE_PIN U15  [get_ports ew_green]
set_property IOSTANDARD  LVCMOS33 [get_ports ew_green]

## =============================================================================
## NOTES FOR ALTERNATE BOARDS:
##   Nexys A7   : Clock = E3, Reset = N17 (BTN0)
##   ZedBoard   : Clock = Y9, refer to board reference manual for LEDs
##   DE10-Nano  : Clock = P11, reset = KEY0
##   Adjust IOSTANDARD to LVCMOS25 for boards with 2.5V I/O banks
## =============================================================================
