# Alpha5 – Zero Skipping MAC Operation

## Overview

This Alpha submission validates the **Zero Skipping MAC Operation** mechanism.
When either the activation or weight value is zero, the design gates the
corresponding flip-flops and MAC inputs to reduce unnecessary switching activity.

This alpha focuses on **functional verification of zero-skipping behavior**
using RTL simulation.

---

## File Structure

- `Alpha5_Zero_Skipping_MAC_Operation/`
  - `hardware/`
    - `case1/`
      - `datafiles/` – input vectors for Case 1
      - `verilog/` – RTL source files for Case 1
      - `sim/`
        - `core_tb.v`
        - `filelist`
    - `case2/`
      - `datafiles/` – input vectors for Case 2
      - `verilog/` – RTL source files for Case 2
      - `sim/`
        - `core_tb.v`
        - `filelist`
  - `README.md`

---

## Zero Skipping Mechanism

The zero-skipping logic operates as follows:

- If an **activation value is zero**, the corresponding MAC operation is gated.
- If a **weight value is zero**, the MAC input is gated.
- Flip-flops associated with inactive paths are also gated to reduce switching.

This mechanism reduces unnecessary computation and achieves power savings.

---

## Case 1: Zero Skipping via Flip-Flop Gating

### Description

Case 1 validates zero-skipping by **gating internal flip-flops** when zero
activations or weights are detected.

### How to Run Case 1

```bash
cd Alpha5_Zero_Skipping_MAC_Operation/hardware/case1/sim
iverilog -f filelist
vvp a.out
```

### Expected Behavior

- MAC operations corresponding to zero inputs are skipped.
- Simulation completes without errors and matches the golden output.
- Functional correctness is preserved despite reduced activity.

---

## Case 2: Zero Skipping via MAC Input Gating

### Description

Case 2 validates zero-skipping by gating MAC inputs directly, preventing
unnecessary multiplications when either operand is zero.

### How to Run Case 2

```bash
cd Alpha5_Zero_Skipping_MAC_Operation/hardware/case2/sim
iverilog -f filelist
vvp a.out
```

### Expected Behavior

- MAC inputs are gated whenever activation or weight is zero.
- Simulation completes without errors and matches the golden output.
- Functional correctness is preserved.

---

## Verification Notes

- Both cases rely on RTL simulation for functional validation.
- Testbenches read input vectors from their respective `datafiles/` directories.
- This alpha validates zero-skipping dataflow behavior, not final power metrics.
