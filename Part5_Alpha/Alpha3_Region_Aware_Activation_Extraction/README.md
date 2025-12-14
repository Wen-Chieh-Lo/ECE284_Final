# Alpha3_Region_Aware_Activation_Extraction

## Overview

This folder contains the **Alpha 3 submission**, which validates the
**Region-Aware Activation Extraction** mechanism in the hardware design.

The goal of this alpha is to verify that:
- Only the required activation region is extracted for convolution
- Unnecessary activation data movement is avoided
- The modified dataflow functions correctly in RTL simulation

This alpha focuses on **hardware-level functional validation** using
Verilog RTL and testbench simulation.

---

## Directory Structure

- Alpha3_Region_Aware_Activation_Extraction/
  - hardware/
    - datafiles/
      - activation.txt
      - weight_kij*.txt
      - psum_kij*.txt
      - output.txt
    - sim/
      - core_tb.v
      - filelist
    - verilog/
      - core.v
      - corelet.v
      - fifo_depth36.v
      - fifo_depth64.v
      - fifo_mux_2_1.v
      - fifo_mux_8_1.v
      - fifo_mux_16_1.v
      - io.v
      - mac_array.v
      - mac_row.v
      - mac_tile.v
      - mac.v
      - offlo.v
      - sfu.v
      - sram_32b_w2048.v
      - sram_128b_w2048.v
  - README.md
---

## How to Run This Alpha

### Step 1: Navigate to the simulation directory

```bash
cd Alpha3_Region_Aware_Activation_Extraction/hardware/sim
```

---

### Step 2: Compile the RTL design

```bash
iverilog -f filelist
```

- The `filelist` specifies all required Verilog source files and include paths.
- Compilation should complete without errors.

---

### Step 3: Run the simulation

```bash
vvp a.out
```

- The testbench (`core_tb.v`) will automatically load input data from the `datafiles/` directory using relative paths.
- Simulation progress and verification messages will be printed to the console.

---

## Expected Output

- The simulation should complete without runtime errors.
- The testbench performs correctness checking using the provided golden reference files.
- A **PASS** message indicates successful validation of this alpha.

---

## Notes

- This alpha focuses on validating **region-aware activation extraction** behavior.
- Partial-sum (`psum_kij*.txt`) files are used as intermediate reference data.
- Final correctness checking is performed after accumulation using `output.txt`.