// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 


module mult_tb;

reg  signed [8 :0] in1;
reg  signed [7 :0] in2;
wire signed [15:0] out;

approx_mult approx_mult_i ( 
	.x(in1),
	.y(in2),
	.out(out)
);

initial begin 

  $dumpfile("mult_tb.vcd");
  $dumpvars(0,mult_tb);

  #1;
  in1 = 9'b0_0100_0101;
  in2 = 8'b0010_1111;

  #1;
  in1 = 9'b0_1111_0111;
  in2 = 8'b0110_1100;

  #1;
  in1 = 9'b0_0110_0101;
  in2 = 8'b1010_1111;

  #1;
  in1 = 9'b0_0000_1101;
  in2 = 8'b1010_0101;

  #1;
  in1 = 9'b0_0111_0000;
  in2 = 8'b1111_1111;

  #1;
  in1 = 9'b0_0000_0001;
  in2 = 8'b1011_1111;

  #1;
  in1 = 9'b0_1000_0001;
  in2 = 8'b0011_0101;

  #1;
  in1 = 9'b0_0110_0101;
  in2 = 8'b1110_1111;

  #1;
  in1 = 9'b0_0111_0001;
  in2 = 8'b0000_1011;

  #1;
  in1 = 9'b0_1111_1101;
  in2 = 8'b1111_1000;

  #1;
  in1 = 9'b0_0010_1111;
  in2 = 8'b1010_0001;

  #1;
  in1 = 9'b0_1110_0001;
  in2 = 8'b1111_0111;

  #1;
  in1 = 9'b0_1111_1101;
  in2 = 8'b0101_0011;

  #10 $finish;
end

endmodule
