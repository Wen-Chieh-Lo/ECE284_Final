// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
/*
module mac (out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;

output signed [psum_bw-1:0] out;
input signed  [bw-1:0] a;  // activation
input signed  [bw-1:0] b;  // weight
input signed  [psum_bw-1:0] c;


wire signed [2*bw:0] product;
wire signed [psum_bw-1:0] psum;
wire signed [bw:0]   a_pad;

assign a_pad = {1'b0, a}; // force to be unsigned number
assign product = a_pad * b;

assign psum = product + c;
assign out = psum;

endmodule
*/

module mac (out, a, b_even, b_odd, c, mode);

parameter bw = 4;
parameter psum_bw = 16;

output signed [psum_bw-1:0] out;
input  signed [bw-1:0] a;  // activation
input signed  [bw-1:0] b_even;  // weight for lower 2bits of activation
input signed  [bw-1:0] b_odd;  // weight for upper 2bits of activation
input signed  [psum_bw-1:0] c;

input mode; // 1: 2bit, 0: 4bit

wire [1:0] a0_raw = a[1:0];
wire [1:0] a1_raw = a[3:2];

wire signed [2:0] a0 = {1'b0, a0_raw};
wire signed [2:0] a1 = {1'b0, a1_raw}; // force to be unsigned number

wire signed [bw+1:0] prod0 = a0 * b_even;
wire signed [bw+1:0] prod1 = a1 * b_odd;

wire signed [psum_bw-1:0] merged_2bit = (prod0 + prod1);
wire signed [psum_bw-1:0] merged_4bit = (prod0 + (prod1 <<< 2));

assign out = c + (mode ? merged_2bit : merged_4bit);

endmodule