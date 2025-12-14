# Part2_SIMD 

## Run Steps

```
cd Part2_SIMD/hardware/sim
iveri filelist
irun
```

## Data Dimensions
#### 1. 4bit Mode

    (Same with Vanilla)
    
#### 2. 2bit Mode
    
    - activation.txt
        - 32bits/row x 36 rows
        - 16 2bit activations per row (ic = 16)
        - 6x6 activation = 36 rows
    
    - weight_kijX.txt
        - 64bits/row x 8 rows
        - 16 4bit weights per row (ic = 16)
        - 8 output channel (oc = 8)
        - X = 0 ~ 8 (3x3 kernels)

    - output.txt
        - 128bits/row x 16 rows 
        - 16 bits for every column
        - 4x4 output size

## Comments
    
    Although we achieved over 90% accuracy, we were not able to generate the correct (ic=16 , oc=8) output data. So we instead used a random debug data to verify RTL.

## Note on Partial-Sum Files

The `psum_kij*.txt` files provided in this project are used **for reference and debugging purposes only**.

Similar to the vanilla configuration, these files represent **intermediate partial-sum results** generated during computation. They are **not used directly for pass/fail verification** in the current testbench.

The final correctness check is performed **after accumulation**, using the values in `output.txt` as the golden reference.
