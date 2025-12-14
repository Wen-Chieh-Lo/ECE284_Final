To execute output-stationary and weight-stationary modes in a reconfigurable manner, the Verilog design files remain identical, and only the simulation testbench, core_tb_p1.v or core_tb_p3.v, needs to be selected.

In the case of core_tb_p1.v, it is identical to Part 1, except that as the input bit-width of the top module core.v increased, unused input bits are simply padded with zeros.

The core_tb_p3.v corresponds to the output-stationary mode, and its inputs are exactly the same as those of core_tb_p1.v. 
Since output-stationary and weight-stationary dataflows require different activation and weight sequences, core_tb_p3.v internally uses task functions, generate_modified_acti and transpose_weight, to enable correct execution without modifying the original input files.
