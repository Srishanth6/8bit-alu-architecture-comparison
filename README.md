# Design and PPA Analysis of an 8-bit ALU Using Ripple-Carry and Carry-Lookahead Architectures

## Overview

This project implements two functionally equivalent 8-bit Arithmetic Logic Units (ALUs) in Verilog:

- **`alu_rca`** uses a structural Ripple-Carry Adder (RCA).
- **`alu_cla`** uses a Carry-Lookahead Adder (CLA).

Both ALUs support the same operations and status flags. The project focuses on modular RTL design, simulation-based verification, and synthesis-based comparison of the architectures.

## Operations

| Opcode | Operation | Notes |
|---|---|---|
| `0000` | Addition (`A + B`) | Carry = carry-out; Overflow = signed overflow |
| `0001` | Subtraction (`A - B`) | Carry flag indicates unsigned borrow |
| `0010` | Bitwise AND | `A & B` |
| `0011` | Bitwise OR | `A \| B` |
| `0100` | Bitwise XOR | `A ^ B` |
| `0101` | Bitwise NOT A | `~A` |
| `0110` | Logical left shift A by 1 | Carry = bit shifted out |
| `0111` | Logical right shift A by 1 | Carry = bit shifted out |
| `1000`–`1111` | Reserved | Expected result `Y = 0`; Zero = 1; other flags = 0 |

### Status flags

- **Zero:** set when the result is `0x00`.
- **Negative:** reflects the most significant bit of the result.
- **Carry:** arithmetic carry/borrow or the bit shifted out; zero for logical operations and reserved opcodes.
- **Overflow:** signed two's-complement overflow for addition/subtraction; zero for non-arithmetic operations.

## Architecture

### Ripple-Carry Adder

Eight full-adder stages are connected in series, with each carry feeding the next stage. It has a simple, regular structure, but carry propagation can create a longer logic path as width increases.

### Carry-Lookahead Adder

Generate and propagate signals are used to calculate carries with expanded lookahead equations. This can reduce logic depth at the cost of additional logic resources. Actual performance depends on the synthesis flow, technology, and timing constraints.

Both ALUs instantiate separate adder units for addition and subtraction to keep the implementation comparison consistent.

## Project Structure

```text
8bit-alu-architecture-comparison/
├── rtl/
│   ├── full_adder.v
│   ├── ripple_carry_adder.v
│   ├── carry_lookahead_adder.v
│   ├── alu_rca.v
│   └── alu_cla.v
├── tb/
│   └── tb_alu_comparison.v
├── sim/
│   └── run_simulation.bat
├── synthesis/
│   └── run_synthesis.ys
├── reports/
│   └── alu_comparison_results.txt
└── README.md
```

## Simulation and Verification

The self-checking testbench includes a behavioral reference model and checks the RCA and CLA outputs/flags against it. Its planned coverage includes arithmetic boundary cases, signed overflow, logical operations, shifts, all 16 opcodes, and reproducible randomized inputs.

The current testbench is configured for 538 checks (32 directed checks and 494 randomized checks). **The latest testbench has not been confirmed to pass in this publishing step**, so do not treat the configured count as proof of a successful run.

### Run on Windows

1. Install Icarus Verilog and ensure `iverilog` and `vvp` are available in PATH.
2. From the project root, run:

   ```bat
   sim\run_simulation.bat
   ```

A successful run should show zero failures and `ALL TESTS PASSED`.

## Generic Synthesis Comparison

The saved comparison was generated using Yosys 0.33 with generic ABC mapping, a flattened synthesis flow, and `ltp -noff` for topological logic-depth analysis.

| Metric | RCA ALU | CLA ALU |
|---|---:|---:|
| Generic mapped logic cells | 287 | 398 |
| Longest topological path | 29 | 19 |
| Wires | 342 | 411 |
| Structural problems reported | 0 | 0 |

The reported longest topological path decreased from 29 to 19 levels, a reduction of approximately 34.48%:

\[
\frac{29-19}{29}\times100\approx34.48\%
\]

In this synthesis run, the CLA used more generic mapped logic cells but had a shorter reported topological path. These metrics describe the complete ALU implementations, not isolated adder blocks.

### Limitations

- Topological logic depth is not propagation delay in nanoseconds.
- Generic mapped cell count is not physical silicon area.
- Power has not been measured.
- Physical PPA requires an appropriate target-cell library, constraints, and technology-specific implementation/timing analysis.
- The synthesis script in `synthesis/` emits generic post-synthesis statistics and output files; its flow is not identical to the flattened flow used for the table above.

Details are in `reports/alu_comparison_results.txt`.

## Running the Yosys Script

With Yosys installed, run from the repository root:

```bash
yosys synthesis/run_synthesis.ys
```

## Future Work

- Run and capture the latest self-checking simulation.
- Add a technology-specific library and static timing analysis.
- Compare physical area and power using a suitable implementation flow.
- Explore hierarchical lookahead structures and wider ALUs.

## Resume / LinkedIn Description

Designed an 8-bit ALU in Verilog using Ripple-Carry and Carry-Lookahead adder architectures. Developed modular RTL and a self-checking testbench for arithmetic, logical, shift, and status-flag behavior. Compared generic Yosys synthesis results to study logic-resource and topological-depth trade-offs.

## License

Student project for educational and portfolio demonstration.
