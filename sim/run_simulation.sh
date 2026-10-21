#!/bin/sh
# Linux equivalent of sim/run_simulation.bat. Run from repository root.
set -e
iverilog -o sim/alu_sim.vvp rtl/full_adder.v rtl/ripple_carry_adder.v rtl/carry_lookahead_adder.v rtl/alu_rca.v rtl/alu_cla.v tb/tb_alu_comparison.v
vvp sim/alu_sim.vvp
