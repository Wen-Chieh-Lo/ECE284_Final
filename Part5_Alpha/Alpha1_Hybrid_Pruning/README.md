# Alpha1_Hybrid_Pruning

## Overview

This folder contains the **Alpha1 submission** for the Hybrid Pruning experiment.

This alpha focuses on validating different pruning strategies
(**unstructured pruning, structured pruning, and hybrid pruning**) using a
Jupyter Notebook–based workflow.

The directory structure follows the **software layout from Part1**, and all
required source files are included in this folder.

---

## Directory Structure

- Alpha1_Hybrid_Pruning/
  - software/
    - models/
      - __init__.py
      - vgg.py
      - vgg_quant.py
      - resnet.py
      - resnet_quant.py
      - quant_layer.py
      - cifar.py
    - result/
      - VGG16_quant/
        - checkpoint.pth
        - model_best.pth.tar
    - Hybrid_Pruning.ipynb
    - Hybrid_Pruning.pdf
  - README.md


This notebook can be opened using:
- Jupyter Notebook
- JupyterLab
- VS Code Jupyter extension

---

### Step 2: Execute the Notebook

Run the notebook **cell by cell from top to bottom**.

No command-line execution is required.
All experiments are executed within the notebook.

---

## What the Notebook Does

During execution, the notebook will:

1. Import model definitions from the `software/models/` directory
2. Construct the CNN model using the provided Python source files
3. Load pretrained checkpoints from `software/result/`
4. Apply different pruning strategies
5. Retrain the pruned models
6. Report accuracy results directly in the cell outputs

No additional configuration or input arguments are required.

---

## Expected Output

The notebook reports classification accuracy for three pruning strategies:

| Pruning Method | Expected Accuracy (Approx.) |
|----------------|-----------------------------|
| Unstructured Pruning | ~88% |
| Structured Pruning | ~73% |
| Hybrid Pruning | ~87% |

The accuracy values are printed directly in the **cell outputs** of the notebook.

---

## Validation Notes

- This alpha is intended for **functional and behavioral validation**.
- The reported accuracies demonstrate relative trends between pruning methods,
  not final optimized performance.
- Checkpoint files in the `result/` directory are used as the starting point
  for pruning and retraining.

---

## Grading Notes

- All required source files are contained within this `Alpha1_Hybrid_Pruning` folder.
- Paths are relative and self-contained.
- TAs can validate this alpha by simply opening the notebook and executing all cells.
- No external scripts or environment configuration is required beyond standard
  Python and PyTorch dependencies.

