// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fifo_depth36 (rd_clk, wr_clk, in, out, rd, wr, o_full, o_empty, reset);

  parameter bw = 4;
  parameter simd = 1;
  parameter lrf_depth = 1;

  input  rd_clk;
  input  wr_clk;
  input  rd;
  input  wr;
  input  reset;
  output o_full;
  output o_empty;
  input  [simd*bw-1:0] in;
  output [simd*bw-1:0] out;

  wire [simd*bw-1:0] out_sub0_0;
  wire [simd*bw-1:0] out_sub0_1;
  wire [simd*bw-1:0] out_sub0_2;
  wire [simd*bw-1:0] out_sub1_0;
  wire full, empty;

  reg [6:0] rd_ptr = 7'b0000000;
  reg [6:0] wr_ptr = 7'b0000000;

  reg [simd*bw-1:0] q0;
  reg [simd*bw-1:0] q1;
  reg [simd*bw-1:0] q2;
  reg [simd*bw-1:0] q3;
  reg [simd*bw-1:0] q4;
  reg [simd*bw-1:0] q5;
  reg [simd*bw-1:0] q6;
  reg [simd*bw-1:0] q7;
  reg [simd*bw-1:0] q8;
  reg [simd*bw-1:0] q9;
  reg [simd*bw-1:0] q10;
  reg [simd*bw-1:0] q11;
  reg [simd*bw-1:0] q12;
  reg [simd*bw-1:0] q13;
  reg [simd*bw-1:0] q14;
  reg [simd*bw-1:0] q15;
  reg [simd*bw-1:0] q16;
  reg [simd*bw-1:0] q17;
  reg [simd*bw-1:0] q18;
  reg [simd*bw-1:0] q19;
  reg [simd*bw-1:0] q20;
  reg [simd*bw-1:0] q21;
  reg [simd*bw-1:0] q22;
  reg [simd*bw-1:0] q23;
  reg [simd*bw-1:0] q24;
  reg [simd*bw-1:0] q25;
  reg [simd*bw-1:0] q26;
  reg [simd*bw-1:0] q27;
  reg [simd*bw-1:0] q28;
  reg [simd*bw-1:0] q29;
  reg [simd*bw-1:0] q30;
  reg [simd*bw-1:0] q31;
  reg [simd*bw-1:0] q32;
  reg [simd*bw-1:0] q33;
  reg [simd*bw-1:0] q34;
  reg [simd*bw-1:0] q35;


 assign empty = (wr_ptr == rd_ptr) ? 1'b1 : 1'b0 ;
 assign full  = ((wr_ptr[5:0] == rd_ptr[5:0]) && (wr_ptr[6] != rd_ptr[6])) ? 1'b1 : 1'b0;

 assign o_full  = full;
 assign o_empty = empty;


  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1a (.in0(q0), .in1(q1), .in2(q2), .in3(q3), .in4(q4), .in5(q5), .in6(q6), .in7(q7),
                                                        .in8(q8), .in9(q9), .in10(q10), .in11(q11), .in12(q12), .in13(q13), .in14(q14), .in15(q15),
                        	                        .sel(rd_ptr[3:0]), .out(out_sub0_0));

  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1b (.in0(q16), .in1(q17), .in2(q18), .in3(q19), .in4(q20), .in5(q21), .in6(q22), .in7(q23),
                                                        .in8(q24), .in9(q25), .in10(q26), .in11(q27), .in12(q28), .in13(q29), .in14(q30), .in15(q31),
                        	                        .sel(rd_ptr[3:0]), .out(out_sub0_1));

  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1c (.in0(q32), .in1(q33), .in2(q34), .in3(q35), .in4({simd*bw{1'b0}}), .in5({simd*bw{1'b0}}), .in6({simd*bw{1'b0}}), .in7({simd*bw{1'b0}}),
                                                        .in8({simd*bw{1'b0}}), .in9({simd*bw{1'b0}}), .in10({simd*bw{1'b0}}), .in11({simd*bw{1'b0}}), .in12({simd*bw{1'b0}}), .in13({simd*bw{1'b0}}), .in14({simd*bw{1'b0}}), .in15({simd*bw{1'b0}}),
                        	                        .sel(rd_ptr[3:0]), .out(out_sub0_2));



  fifo_mux_2_1 #(.bw(bw)) fifo_mux_2_1a   (.in0(out_sub0_0), .in1(out_sub0_1), .sel(rd_ptr[4]), .out(out_sub1_0));
  
  fifo_mux_2_1 #(.bw(bw)) fifo_mux_2_1c   (.in0(out_sub1_0), .in1(out_sub0_2), .sel(rd_ptr[5]), .out(out));




 always @ (posedge rd_clk) begin
   if (reset) begin
      rd_ptr <= 7'b0000000;
   end
   else if ((rd == 1) && (empty == 0)) begin
      if(rd_ptr[5:0] == 6'd35) begin
        rd_ptr[5:0] <= 6'b000000;
        rd_ptr[6]   <= ~rd_ptr[6];
      end else begin
        rd_ptr[5:0] <= rd_ptr[5:0] + 1;
      end
   end
 end


 always @ (posedge wr_clk) begin
   if (reset) begin
      wr_ptr <= 7'b0000000;
   end
   else begin 
      if ((wr == 1) && (full == 0)) begin
        if(rd_ptr[5:0] == 6'd35) begin
          wr_ptr[5:0] <= 6'b000000;
          wr_ptr[6]   <= ~wr_ptr[6];
        end else begin
          wr_ptr[5:0] <= wr_ptr[5:0] + 1;
        end
      end

      if (wr == 1) begin
        case (wr_ptr[5:0])
         6'b000000   :    q0  <= in ;
         6'b000001   :    q1  <= in ;
         6'b000010   :    q2  <= in ;
         6'b000011   :    q3  <= in ;
         6'b000100   :    q4  <= in ;
         6'b000101   :    q5  <= in ;
         6'b000110   :    q6  <= in ;
         6'b000111   :    q7  <= in ;
         6'b001000   :    q8  <= in ;
         6'b001001   :    q9  <= in ;
         6'b001010   :    q10 <= in ;
         6'b001011   :    q11 <= in ;
         6'b001100   :    q12 <= in ;
         6'b001101   :    q13 <= in ;
         6'b001110   :    q14 <= in ;
         6'b001111   :    q15 <= in ;

         6'b010000   :    q16  <= in ;
         6'b010001   :    q17  <= in ;
         6'b010010   :    q18  <= in ;
         6'b010011   :    q19  <= in ;
         6'b010100   :    q20  <= in ;
         6'b010101   :    q21  <= in ;
         6'b010110   :    q22  <= in ;
         6'b010111   :    q23  <= in ;
         6'b011000   :    q24  <= in ;
         6'b011001   :    q25  <= in ;
         6'b011010   :    q26 <= in ;
         6'b011011   :    q27 <= in ;
         6'b011100   :    q28 <= in ;
         6'b011101   :    q29 <= in ;
         6'b011110   :    q30 <= in ;
         6'b011111   :    q31 <= in ;

         6'b100000   :    q32  <= in ;
         6'b100001   :    q33  <= in ;
         6'b100010   :    q34  <= in ;
         6'b100011   :    q35  <= in ;

        endcase
      end
   end

 end


endmodule
