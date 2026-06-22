#!/bin/bash
# =============================================================================
# Script      : run_sim.sh
# Description : Compile and simulate the traffic light controller using
#               Icarus Verilog (free, open-source). Works on Linux/macOS/WSL.
#
# Install Icarus: sudo apt install iverilog gtkwave   (Ubuntu/Debian/WSL)
#                 brew install icarus-verilog gtkwave  (macOS)
#                 Windows: use WSL or download from http://bleyer.org/icarus/
# =============================================================================

set -e  # Exit immediately if any command fails

echo "============================================================"
echo " FPGA Traffic Light Controller — Icarus Verilog Simulation"
echo "============================================================"

# ── Step 1: Create waveform output directory ──────────────────────────────────
mkdir -p waveforms

# ── Step 2: Compile RTL + Testbench ──────────────────────────────────────────
echo "[1/3] Compiling Verilog files..."
iverilog -Wall \
    -o simulation/traffic_light_sim \
    -I rtl \
    rtl/traffic_light_controller.v \
    tb/tb_traffic_light_controller.v

echo "      Compilation successful ✓"

# ── Step 3: Run Simulation ────────────────────────────────────────────────────
echo "[2/3] Running simulation..."
vvp simulation/traffic_light_sim

echo "      Simulation complete ✓"

# ── Step 4: Open Waveform in GTKWave (optional — comment out if not installed) ──
echo "[3/3] Opening waveform in GTKWave..."
if command -v gtkwave &> /dev/null; then
    gtkwave waveforms/traffic_light_sim.vcd &
    echo "      GTKWave launched ✓"
else
    echo "      GTKWave not installed. VCD file saved at: waveforms/traffic_light_sim.vcd"
    echo "      Upload to: https://vc.drom.io  or install gtkwave to view waveform."
fi

echo ""
echo "============================================================"
echo " Simulation Complete. Check console output for PASS/FAIL."
echo "============================================================"
