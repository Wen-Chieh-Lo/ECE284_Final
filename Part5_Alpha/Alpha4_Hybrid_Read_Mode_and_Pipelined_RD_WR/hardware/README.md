# Alpha4 – Hybrid FIFO Read Mode and Pipelined RD/WR

## Overview

This Alpha submission validates the **Hybrid FIFO Read Mode** and **Pipelined Read/Write**
mechanism in the hardware design.

The design supports two FIFO read modes:
- **Propagate**: activation data propagates row by row
- **Simultaneous**: activation data is broadcast to all rows at once

These modes reduce stall cycles and improve overall utilization.
Functional correctness is verified via RTL simulation.

---

## Directory Structure

- `hardware/`
  - `datafiles/` – input vectors and golden outputs
  - `verilog/` – RTL source files
  - `sim/`
    - `core_tb.v` – testbench
    - `filelist` – compilation file list
    - `a.out` – simulation executable (generated)

---

## How to Run This Alpha

Navigate to the simulation directory:

```bash
cd Alpha4_Hybrid_Read_Mode_and_Pipelined_RD_WR/hardware/sim
iverilog -f filelist
vvp a.out
```

---

## Expected Behavior

The testbench reads input vectors from datafiles/ using relative paths.

Partial sums (psum_kij*.txt) are generated internally and accumulated.

The final accumulated result is compared against output.txt.

Simulation completes without errors if the hybrid read mode operates correctly.

---

## Verification Notes

psum_kij*.txt files represent intermediate partial-sum results.

Only output.txt is used for final pass/fail verification.

This alpha focuses on validating FIFO behavior and dataflow correctness,
not final performance optimization.
