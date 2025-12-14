// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_proposed (out, a, b, c);

parameter bw = 8;
parameter psum_bw = 16;

output signed [psum_bw-1:0] out;
input signed  [bw-1:0] a;  // activation
input signed  [bw-1:0] b;  // weight
input signed  [psum_bw-1:0] c;


wire signed [2*bw-1:0] product;
wire signed [psum_bw-1:0] psum;
wire signed [bw:0]   a_pad;

assign a_pad = {1'b0, a}; // force to be unsigned number
// x should be {1'b0, 8bit unsigned}, y should be {sign 1bit, int 7bit}
approx_mult approx_mult_i(.x(a_pad), .y(b), .out(product));

assign psum = product + c;
assign out = psum;

endmodule
