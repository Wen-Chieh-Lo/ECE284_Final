// x should be {1'b0, 8bit unsigned}, y should be {1bit sign, 7bit int}
module approx_mult (input signed [8:0] x, input signed [7:0] y, output signed [15:0] out);

    // 9-bit 2's complement of x  (x_neg = -x mod 2^9)
    wire signed [8:0] x_neg;
    assign x_neg = ~x + 9'd1;

    // ab[row][col] : row 0~7, col 0~7  => partial products
    wire [7:0] ab [0:7];
    wire       msb_;



    //////////////////////////////////
    /// partial product generation ///
    //////////////////////////////////
    genvar i, j, k;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_row
            for (j = 1; j < 8; j = j + 1) begin : gen_col
            	assign ab[i][j] = x[7 - i] & y[7 - j];
            end
        end
	for (k=0; k<8; k=k+1) begin: gen_twoscomp
	    assign ab[k][0] = x_neg[7-k] & y[7];
	end
    endgenerate

    // extra MSB pp: x_neg[8] * y[7]
    assign msb_ = x_neg[8] & y[7];



    ///////////////
    /// Stage 1 ///
    ///////////////
    wire c_h0_1s, s_h0_1s;
    wire c_h1_1s, s_h1_1s;
    wire c_h2_1s, s_h2_1s;

    wire c_f0_1s, s_f0_1s;

    wire s_m0_1s,  c_m0_1s;
    wire s_m1_1s,  c_m1_1s;
    wire s_m2_1s,  c_m2_1s;
    wire s_m3_1s,  c_m3_1s;
    wire s_m4_1s,  c_m4_1s;
    wire s_m5_1s,  c_m5_1s;

    // accurate part
    wire s_a0_1s, c_a0_1s, t_a0_1s;
    wire s_a1_1s, c_a1_1s;

    // half adders
    HA HA_h0 (.x(ab[3][7]), .y(ab[4][6]), .s(s_h0_1s), .c(c_h0_1s));
    HA HA_h1 (.x(ab[5][3]), .y(ab[6][2]), .s(s_h1_1s), .c(c_h1_1s));
    HA HA_h2 (.x(ab[4][1]), .y(ab[5][0]), .s(s_h2_1s), .c(c_h2_1s));

    // full adder
    FA FA_f0 (.x(ab[4][2]), .y(ab[5][1]), .z(ab[6][0]), .s(s_f0_1s), .c(c_f0_1s));

    // Ahma 4:2 (approx)
    Ahma4to2 M0 (.x1(ab[2][7]), .x2(ab[3][6]), .x3(ab[4][5]), .x4(ab[5][4]), .s(s_m0_1s), .c(c_m0_1s));
    Ahma4to2 M1 (.x1(ab[1][7]), .x2(ab[2][6]), .x3(ab[3][5]), .x4(ab[4][4]), .s(s_m1_1s), .c(c_m1_1s));
    Ahma4to2 M2 (.x1(ab[0][7]), .x2(ab[1][6]), .x3(ab[2][5]), .x4(ab[3][4]), .s(s_m2_1s), .c(c_m2_1s));
    Ahma4to2 M3 (.x1(ab[4][3]), .x2(ab[5][2]), .x3(ab[6][1]), .x4(ab[7][0]), .s(s_m3_1s), .c(c_m3_1s));
    Ahma4to2 M4 (.x1(ab[0][6]), .x2(ab[1][5]), .x3(ab[2][4]), .x4(ab[3][3]), .s(s_m4_1s), .c(c_m4_1s));
    Ahma4to2 M5 (.x1(ab[0][5]), .x2(ab[1][4]), .x3(ab[2][3]), .x4(ab[3][2]), .s(s_m5_1s), .c(c_m5_1s));

    // exact 4:2 for accurate part (comp5to3)
    comp5to3 C0 (.x1(ab[0][4]), .x2(ab[1][3]), .x3(ab[2][2]), .x4(ab[3][1]), .Tin(1'b0),
                 .s(s_a0_1s),   .c(c_a0_1s),   .Tout(t_a0_1s));

    FA FA_a1 (.x(ab[0][3]), .y(ab[1][2]), .z(t_a0_1s), .s(s_a1_1s), .c(c_a1_1s));



    ///////////////
    /// Stage 2 ///
    ///////////////
    wire c_h4_2s, s_h4_2s;

    wire s_m7_2s,  c_m7_2s;
    wire s_m8_2s,  c_m8_2s;
    wire s_m9_2s,  c_m9_2s;
    wire s_m10_2s, c_m10_2s;
    wire s_m11_2s, c_m11_2s;
    wire s_m12_2s, c_m12_2s;
    wire s_m13_2s, c_m13_2s;

    // accurate part
    wire s_a2_2s, c_a2_2s, t_a2_2s;
    wire s_a3_2s, c_a3_2s, t_a3_2s;
    wire s_a4_2s, c_a4_2s, t_a4_2s;
    wire s_a5_2s, c_a5_2s;

    // HA for (ab[5][7], ab[6][6])
    HA HA_h4 (.x(ab[5][7]), .y(ab[6][6]), .s(s_h4_2s), .c(c_h4_2s));

    // Ahma & Ansari in this stage
    Ahma4to2   M7  (.x1(ab[4][7]), .x2(ab[5][6]), .x3(ab[6][5]), .x4(ab[7][4]), .s(s_m7_2s),  .c(c_m7_2s));
    Ahma4to2   M8  (.x1(ab[5][5]), .x2(ab[6][4]), .x3(ab[7][3]), .x4(s_h0_1s),  .s(s_m8_2s),  .c(c_m8_2s));
    Ansari4to2 M9  (.x1(ab[6][3]), .x2(c_h0_1s),  .x3(ab[7][2]), .x4(s_m0_1s),  .s(s_m9_2s),  .c(c_m9_2s));
    Ansari4to2 M10 (.x1(ab[7][1]), .x2(c_m0_1s),  .x3(s_m1_1s),  .x4(s_h1_1s),  .s(s_m10_2s), .c(c_m10_2s));
    Ansari4to2 M11 (.x1(c_m1_1s),  .x2(c_h1_1s),  .x3(s_m2_1s),  .x4(s_m3_1s),  .s(s_m11_2s), .c(c_m11_2s));
    Ansari4to2 M12 (.x1(c_m2_1s),  .x2(c_m3_1s),  .x3(s_m4_1s),  .x4(s_f0_1s),  .s(s_m12_2s), .c(c_m12_2s));
    Ansari4to2 M13 (.x1(c_m4_1s),  .x2(c_f0_1s),  .x3(s_m5_1s),  .x4(s_h2_1s),  .s(s_m13_2s), .c(c_m13_2s));

    // exact 4:2
    comp5to3 C2_0 (.x1(c_m5_1s),  .x2(c_h2_1s), .x3(ab[4][0]), .x4(s_a0_1s), .Tin(1'b0),
                   .s(s_a2_2s),   .c(c_a2_2s),  .Tout(t_a2_2s));

    comp5to3 C2_1 (.x1(ab[2][1]), .x2(ab[3][0]), .x3(s_a1_1s), .x4(c_a0_1s), .Tin(t_a2_2s),
                   .s(s_a3_2s),   .c(c_a3_2s),   .Tout(t_a3_2s));

    comp5to3 C2_2 (.x1(ab[0][2]), .x2(ab[1][1]), .x3(ab[2][0]), .x4(c_a1_1s), .Tin(t_a3_2s),
                   .s(s_a4_2s),   .c(c_a4_2s),   .Tout(t_a4_2s));

    FA FA_a5 (.x(ab[1][0]), .y(ab[0][1]), .z(t_a4_2s), .s(s_a5_2s), .c(c_a5_2s));



    ////////////////////////////////////
    /// Stage 3 (final accumulation) ///
    ////////////////////////////////////
    wire c_h6_3s;
    wire c_f1_3s, c_f2_3s, c_f3_3s, c_f4_3s, c_f5_3s;
    wire c_f6_3s, c_f7_3s, c_f8_3s, c_f9_3s, c_f10_3s;
    wire c_f11_3s, c_f12_3s, c_f13_3s;

    wire [15:0] o;

    // o[0] = ab[7,7]
    assign o[0] = ab[7][7];

    HA HA_h6  (.x(ab[6][7]), .y(ab[7][6]), .s(o[1]), .c(c_h6_3s));
    FA FA_f1  (.x(ab[7][5]), .y(s_h4_2s),  .z(c_h6_3s),  .s(o[2]),  .c(c_f1_3s));
    FA FA_f2  (.x(s_m7_2s),  .y(c_h4_2s),  .z(c_f1_3s),  .s(o[3]),  .c(c_f2_3s));
    FA FA_f3  (.x(s_m8_2s),  .y(c_m7_2s),  .z(c_f2_3s),  .s(o[4]),  .c(c_f3_3s));
    FA FA_f4  (.x(s_m9_2s),  .y(c_m8_2s),  .z(c_f3_3s),  .s(o[5]),  .c(c_f4_3s));
    FA FA_f5  (.x(s_m10_2s), .y(c_m9_2s),  .z(c_f4_3s),  .s(o[6]),  .c(c_f5_3s));
    FA FA_f6  (.x(s_m11_2s), .y(c_m10_2s), .z(c_f5_3s),  .s(o[7]),  .c(c_f6_3s));
    FA FA_f7  (.x(s_m12_2s), .y(c_m11_2s), .z(c_f6_3s),  .s(o[8]),  .c(c_f7_3s));
    FA FA_f8  (.x(s_m13_2s), .y(c_m12_2s), .z(c_f7_3s),  .s(o[9]),  .c(c_f8_3s));
    FA FA_f9  (.x(s_a2_2s),  .y(c_m13_2s), .z(c_f8_3s),  .s(o[10]), .c(c_f9_3s));
    FA FA_f10 (.x(s_a3_2s),  .y(c_a2_2s),  .z(c_f9_3s),  .s(o[11]), .c(c_f10_3s));
    FA FA_f11 (.x(s_a4_2s),  .y(c_a3_2s),  .z(c_f10_3s), .s(o[12]), .c(c_f11_3s));
    FA FA_f12 (.x(s_a5_2s),  .y(c_a4_2s),  .z(c_f11_3s), .s(o[13]), .c(c_f12_3s));
    FA FA_f13 (.x(ab[0][0]), .y(c_a5_2s),  .z(c_f12_3s), .s(o[14]), .c(c_f13_3s));

    wire dump_c15;
    HA HA_f14 (.x(msb_), .y(c_f13_3s), .s(o[15]), .c(dump_c15));

    assign out = o;

endmodule
