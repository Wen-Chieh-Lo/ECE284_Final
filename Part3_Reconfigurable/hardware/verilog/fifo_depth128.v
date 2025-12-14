// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fifo_depth128 (rd_clk, wr_clk, in, out, rd, wr, o_full, o_empty, reset);

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
  wire [simd*bw-1:0] out_sub0_3;
  wire [simd*bw-1:0] out_sub0_4;
  wire [simd*bw-1:0] out_sub0_5;
  wire [simd*bw-1:0] out_sub0_6;
  wire [simd*bw-1:0] out_sub0_7;
  // wire [simd*bw-1:0] out_sub1_0;
  // wire [simd*bw-1:0] out_sub1_1;
  wire full, empty;

  reg [7:0] rd_ptr = 8'b00000000;
  reg [7:0] wr_ptr = 8'b00000000;
  reg [simd*bw-1:0] q [0:127];

 assign empty = (wr_ptr == rd_ptr) ? 1'b1 : 1'b0 ;
 assign full  = ((wr_ptr[6:0] == rd_ptr[6:0]) && (wr_ptr[7] != rd_ptr[7])) ? 1'b1 : 1'b0;
 assign o_full  = full;
 assign o_empty = empty;

  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1a (.in0(q[0]), .in1(q[1]),   .in2(q[2]),   .in3(q[3]),   .in4(q[4]),   .in5(q[5]),   .in6(q[6]),   .in7(q[7]),
                                           .in8(q[8]), .in9(q[9]), .in10(q[10]), .in11(q[11]), .in12(q[12]), .in13(q[13]), .in14(q[14]), .in15(q[15]),
                        	           .sel(rd_ptr[3:0]), .out(out_sub0_0));

  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1b (.in0(q[16]), .in1(q[17]),  .in2(q[18]),  .in3(q[19]),  .in4(q[20]),  .in5(q[21]),  .in6(q[22]),  .in7(q[23]),
                                           .in8(q[24]), .in9(q[25]), .in10(q[26]), .in11(q[27]), .in12(q[28]), .in13(q[29]), .in14(q[30]), .in15(q[31]),
                        	           .sel(rd_ptr[3:0]), .out(out_sub0_1));

  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1c (.in0(q[32]), .in1(q[33]),  .in2(q[34]),  .in3(q[35]),  .in4(q[36]),  .in5(q[37]),  .in6(q[38]),  .in7(q[39]),
                                           .in8(q[40]), .in9(q[41]), .in10(q[42]), .in11(q[43]), .in12(q[44]), .in13(q[45]), .in14(q[46]), .in15(q[47]),
                        	           .sel(rd_ptr[3:0]), .out(out_sub0_2));

  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1d (.in0(q[48]), .in1(q[49]),  .in2(q[50]),  .in3(q[51]),  .in4(q[52]),  .in5(q[53]),  .in6(q[54]),  .in7(q[55]),
                                           .in8(q[56]), .in9(q[57]), .in10(q[58]), .in11(q[59]), .in12(q[60]), .in13(q[61]), .in14(q[62]), .in15(q[63]),
                        	           .sel(rd_ptr[3:0]), .out(out_sub0_3));

  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1e (.in0(q[64]), .in1(q[65]),  .in2(q[66]),  .in3(q[67]),  .in4(q[68]),  .in5(q[69]),  .in6(q[70]),  .in7(q[71]),
                                           .in8(q[72]), .in9(q[73]), .in10(q[74]), .in11(q[75]), .in12(q[76]), .in13(q[77]), .in14(q[78]), .in15(q[79]),
                        	           .sel(rd_ptr[3:0]), .out(out_sub0_4));

  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1f (.in0(q[80]), .in1(q[81]),  .in2(q[82]),  .in3(q[83]),  .in4(q[84]),  .in5(q[85]),  .in6(q[86]),  .in7(q[87]),
                                           .in8(q[88]), .in9(q[89]), .in10(q[90]), .in11(q[91]), .in12(q[92]), .in13(q[93]), .in14(q[94]), .in15(q[95]),
                        	           .sel(rd_ptr[3:0]), .out(out_sub0_5));

  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1g ( .in0(q[96]),  .in1(q[97]),   .in2(q[98]),   .in3(q[99]),  .in4(q[100]),  .in5(q[101]),  .in6(q[102]),  .in7(q[103]),
                                           .in8(q[104]), .in9(q[105]), .in10(q[106]), .in11(q[107]), .in12(q[108]), .in13(q[109]), .in14(q[110]), .in15(q[111]),
                        	           .sel(rd_ptr[3:0]), .out(out_sub0_6));

  fifo_mux_16_1 #(.bw(bw)) fifo_mux_16_1h (.in0(q[112]), .in1(q[113]),  .in2(q[114]),  .in3(q[115]),  .in4(q[116]),  .in5(q[117]),  .in6(q[118]),  .in7(q[119]),
                                           .in8(q[120]), .in9(q[121]), .in10(q[122]), .in11(q[123]), .in12(q[124]), .in13(q[125]), .in14(q[126]), .in15(q[127]),
                        	           .sel(rd_ptr[3:0]), .out(out_sub0_7));

  fifo_mux_8_1  #(.bw(bw)) fifo_mux_8_2a (.in0(out_sub0_0), .in1(out_sub0_1),  .in2(out_sub0_2),  .in3(out_sub0_3),  .in4(out_sub0_4),  .in5(out_sub0_5),  .in6(out_sub0_6),  .in7(out_sub0_7),
                        	          .sel(rd_ptr[6:4]), .out(out));
  

 always @ (posedge rd_clk) begin
   if (reset) begin
      rd_ptr <= 8'b0000000;
   end
   else if ((rd == 1) && (empty == 0)) begin
      rd_ptr <= rd_ptr + 1;
   end
 end


 always @ (posedge wr_clk) begin
   if (reset) begin
      wr_ptr <= 8'b00000000;
   end
   else begin 
      if ((wr == 1) && (full == 0)) begin
        wr_ptr <= wr_ptr + 1;
      end

      if (wr == 1) begin
        case (wr_ptr[6:0])

           7'b0000000: q[0]   <= in;
           7'b0000001: q[1]   <= in;
           7'b0000010: q[2]   <= in;
           7'b0000011: q[3]   <= in;
           7'b0000100: q[4]   <= in;
           7'b0000101: q[5]   <= in;
           7'b0000110: q[6]   <= in;
           7'b0000111: q[7]   <= in;
           7'b0001000: q[8]   <= in;
           7'b0001001: q[9]   <= in;
           7'b0001010: q[10]  <= in;
           7'b0001011: q[11]  <= in;
           7'b0001100: q[12]  <= in;
           7'b0001101: q[13]  <= in;
           7'b0001110: q[14]  <= in;
           7'b0001111: q[15]  <= in;
           7'b0010000: q[16]  <= in;
           7'b0010001: q[17]  <= in;
           7'b0010010: q[18]  <= in;
           7'b0010011: q[19]  <= in;
           7'b0010100: q[20]  <= in;
           7'b0010101: q[21]  <= in;
           7'b0010110: q[22]  <= in;
           7'b0010111: q[23]  <= in;
           7'b0011000: q[24]  <= in;
           7'b0011001: q[25]  <= in;
           7'b0011010: q[26]  <= in;
           7'b0011011: q[27]  <= in;
           7'b0011100: q[28]  <= in;
           7'b0011101: q[29]  <= in;
           7'b0011110: q[30]  <= in;
           7'b0011111: q[31]  <= in;
           7'b0100000: q[32]  <= in;
           7'b0100001: q[33]  <= in;
           7'b0100010: q[34]  <= in;
           7'b0100011: q[35]  <= in;
           7'b0100100: q[36]  <= in;
           7'b0100101: q[37]  <= in;
           7'b0100110: q[38]  <= in;
           7'b0100111: q[39]  <= in;
           7'b0101000: q[40]  <= in;
           7'b0101001: q[41]  <= in;
           7'b0101010: q[42]  <= in;
           7'b0101011: q[43]  <= in;
           7'b0101100: q[44]  <= in;
           7'b0101101: q[45]  <= in;
           7'b0101110: q[46]  <= in;
           7'b0101111: q[47]  <= in;
           7'b0110000: q[48]  <= in;
           7'b0110001: q[49]  <= in;
           7'b0110010: q[50]  <= in;
           7'b0110011: q[51]  <= in;
           7'b0110100: q[52]  <= in;
           7'b0110101: q[53]  <= in;
           7'b0110110: q[54]  <= in;
           7'b0110111: q[55]  <= in;
           7'b0111000: q[56]  <= in;
           7'b0111001: q[57]  <= in;
           7'b0111010: q[58]  <= in;
           7'b0111011: q[59]  <= in;
           7'b0111100: q[60]  <= in;
           7'b0111101: q[61]  <= in;
           7'b0111110: q[62]  <= in;
           7'b0111111: q[63]  <= in;
           7'b1000000: q[64]  <= in;
           7'b1000001: q[65]  <= in;
           7'b1000010: q[66]  <= in;
           7'b1000011: q[67]  <= in;
           7'b1000100: q[68]  <= in;
           7'b1000101: q[69]  <= in;
           7'b1000110: q[70]  <= in;
           7'b1000111: q[71]  <= in;
           7'b1001000: q[72]  <= in;
           7'b1001001: q[73]  <= in;
           7'b1001010: q[74]  <= in;
           7'b1001011: q[75]  <= in;
           7'b1001100: q[76]  <= in;
           7'b1001101: q[77]  <= in;
           7'b1001110: q[78]  <= in;
           7'b1001111: q[79]  <= in;
           7'b1010000: q[80]  <= in;
           7'b1010001: q[81]  <= in;
           7'b1010010: q[82]  <= in;
           7'b1010011: q[83]  <= in;
           7'b1010100: q[84]  <= in;
           7'b1010101: q[85]  <= in;
           7'b1010110: q[86]  <= in;
           7'b1010111: q[87]  <= in;
           7'b1011000: q[88]  <= in;
           7'b1011001: q[89]  <= in;
           7'b1011010: q[90]  <= in;
           7'b1011011: q[91]  <= in;
           7'b1011100: q[92]  <= in;
           7'b1011101: q[93]  <= in;
           7'b1011110: q[94]  <= in;
           7'b1011111: q[95]  <= in;
           7'b1100000: q[96]  <= in;
           7'b1100001: q[97]  <= in;
           7'b1100010: q[98]  <= in;
           7'b1100011: q[99]  <= in;
           7'b1100100: q[100] <= in;
           7'b1100101: q[101] <= in;
           7'b1100110: q[102] <= in;
           7'b1100111: q[103] <= in;
           7'b1101000: q[104] <= in;
           7'b1101001: q[105] <= in;
           7'b1101010: q[106] <= in;
           7'b1101011: q[107] <= in;
           7'b1101100: q[108] <= in;
           7'b1101101: q[109] <= in;
           7'b1101110: q[110] <= in;
           7'b1101111: q[111] <= in;
           7'b1110000: q[112] <= in;
           7'b1110001: q[113] <= in;
           7'b1110010: q[114] <= in;
           7'b1110011: q[115] <= in;
           7'b1110100: q[116] <= in;
           7'b1110101: q[117] <= in;
           7'b1110110: q[118] <= in;
           7'b1110111: q[119] <= in;
           7'b1111000: q[120] <= in;
           7'b1111001: q[121] <= in;
           7'b1111010: q[122] <= in;
           7'b1111011: q[123] <= in;
           7'b1111100: q[124] <= in;
           7'b1111101: q[125] <= in;
           7'b1111110: q[126] <= in;
           7'b1111111: q[127] <= in;
	
        endcase
      end
   end

 end


endmodule
