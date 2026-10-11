@echo off
echo Compiling and running 8-bit ALU comparison...
iverilog -o sim/alu_sim.exe rtl/full_adder.v rtl/ripple_carry_adder.v rtl/carry_lookahead_adder.v rtl/alu_rca.v rtl/alu_cla.v tb/tb_alu_comparison.v
if errorlevel 1 (
    echo Compilation failed.
    exit /b 1
)
vvp sim/alu_sim.exe
echo Simulation finished.
