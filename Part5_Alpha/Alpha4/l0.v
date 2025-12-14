// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module l0 (clk, in, out, rd, wr, o_full, reset, o_ready, weight_or_activation);

  parameter row  = 8;
  parameter bw = 4;

  input  clk;
  input  wr;
  input  rd;
  input  reset;
  input  weight_or_activation;
  input  [row*bw-1:0] in;
  output [row*bw-1:0] out;
  output o_full;
  output o_ready;

  wire [row-1:0] empty;
  wire [row-1:0] full;
  reg [row-1:0] rd_en;
  
  genvar i;

  assign o_ready = !(|full);
  assign o_full  = (|full);


  for(i = 0; i < row; i=i+1)begin
        fifo_depth64 #(.bw(bw)) fifo_inst(
         .rd_clk(clk),
         .wr_clk(clk),
         .rd(rd_en[i]),
         .wr(wr),
         .reset(reset),
         .o_full(full[i]),
         .o_empty(empty[i]),
         .in(in[(i+1)*bw- 1 : i*bw]),
         .out(out[(i+1)*bw- 1 : i*bw])
      );
   end

  always @ (posedge clk) begin
   if (reset) begin
      rd_en <= 8'b00000000;
   end
   else
      //Version 1
      if (weight_or_activation)begin
         rd_en <= {8{rd}};
      end
       //Version 2
      else begin
         rd_en <= {rd_en[row-2:0],rd};
      end
      
    end

endmodule
