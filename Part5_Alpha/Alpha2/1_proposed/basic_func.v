module HA(input x, input y, output s, output c);
	assign s = x ^ y;
	assign c = x & y;
endmodule

module FA(input x, input y, input z, output s, output c);
	assign s = x ^ y ^ z;
	assign c = (x&y) | (x&z) | (y&z);
endmodule

module comp5to3 (input x1, input x2, input x3, input x4, input Tin, output s, output c, output Tout);
	wire temp;
	FA FA_1 (.x(x4),   .y(x3), .z(x2),  .s(temp), .c(Tout));
	FA FA_2 (.x(temp), .y(x1), .z(Tin), .s(s),    .c(c));
	
endmodule

module Ahma4to2(input x1, input x2, input x3, input x4, output s, output c);
	wire temp1, temp2;

	assign temp1 = ~(x1 | x2);
	assign temp2 = ~(x3 | x4);

	assign c = ~(temp1 | temp2);
	assign s = ~(temp1 & temp2);

endmodule

module Ansari4to2(input x1, input x2, input x3, input x4, output s, output c);
	assign c = ~((~(x1 & x2)) & (~(x3 & x4)));
	assign s = ~((~(x1 | x2)) & (~(x3 | x4)));

endmodule


