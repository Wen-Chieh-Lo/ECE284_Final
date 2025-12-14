# Part1_Vanilla – Hardware Simulation Data Files

## Overview

The `datafiles/` directory contains the input vectors and golden reference outputs used by the testbench and verification scripts for **Part1_Vanilla**.

All data files are accessed using **relative paths** so that they can be replaced with TA-provided vectors during grading.

---

## Directory Structure

- `datafiles/`
  - `activation.txt`
  - `weight_kij0.txt`
  - `weight_kij1.txt`
  - `...`
  - `psum_kij0.txt`
  - `psum_kij1.txt`
  - `...`
  - `psum_kij8.txt`
  - `output.txt`

---

## File Descriptions

### Activation File

- **`activation.txt`**
  - Contains input activation values used by the testbench.
  - Shared across all kernel/weight configurations.

---

### Weight Files

- **`weight_kij*.txt`**
  - Contains weight values for different kernel index configurations.
  - Files are named using the following convention:
    ```
    weight_kij0.txt
    weight_kij1.txt
    ...
    ```

---

### Partial-Sum Files (Intermediate Results)

- **`psum_kij*.txt`**
  - Contains **partial-sum (intermediate) results** for verification.
  - Files are named as:
    ```
    psum_kij0.txt
    psum_kij1.txt
    ...
    psum_kij8.txt
    ```
  - Each `psum_kij*.txt` corresponds to the partial output generated using the matching `weight_kij*.txt`.

⚠️ **Note:**  
These files represent **intermediate partial-sum results only**. They are **not** the final output of the design.

---

### Final Output File (Golden Reference)

- **`output.txt`**
  - Contains the **final golden output** after accumulating all partial sums.
  - This file is used as the **actual reference for correctness checking** in simulation.

---

## Verification Methodology

The provided testbench (`core_tb.v`) is designed to:

1. Read **partial-sum values** generated internally during computation.
2. Perform an **accumulation step** over these partial sums.
3. Compare the accumulated result against **`output.txt`** for final verification.

As a result:

- `psum_kij*.txt` files are used to represent **intermediate results**.
- **Only `output.txt` is used for pass/fail verification** in the current testbench implementation.

This behavior is consistent with the original design of `core_tb.v`, which expects a **single output file** for validation.

---

## Summary Table

| File Type | Naming Convention |
|----------|------------------|
| Activations | `activation.txt` |
| Weights | `weight_kij*.txt` |
| Partial Sums (Intermediate) | `psum_kij0.txt` – `psum_kij8.txt` |
| Final Golden Output | `output.txt` |
