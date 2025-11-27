module core  (
	input clk,
    input reset,
	input [34:0] inst,
	output ofifo_valid,
    input [bw*row-1 : 0 ]  D_xmem, 
    output [psum_bw*col-1 : 0 ] sfp_out
); 
    parameter bw  = 8;
    parameter col = 8;
    parameter psum_bw = 16;
    parameter row = 4;


wire [31:0] Q_xmem;
wire l0_or_ififo;
sram_32b_w2048 #(
    .num(2048)
) input_mem(
    .CLK(clk),
    .WEN(inst[18]),
    .CEN(inst[19]),
    .D(D_xmem),
    .A(inst[17:7]),
    .Q(Q_xmem)
);

wire [127:0] D_pmem, Q_pmem;
genvar i;
for(i = 0; i < 4; i = i + 1)begin
    sram_32b_w2048 #(
    .num(2048)
    ) partial_mem(
        .CLK(clk),
        .WEN(inst[31]),
        .CEN(inst[32]),
        .D(D_pmem[(i+1) * 32 - 1: i*32]),
        .A(inst[30:20]),
        .Q(Q_pmem[(i+1) * 32 - 1: i*32])
    );
end



corelet #(

) corelet_inst(
    .clk(clk),
    .reset(reset),
    .inst(inst[1:0]), // 1st bit : execute  0th: Load Kernel
    .l0_or_ififo(inst[17]),
    .l0_rd(inst[3]),
    .l0_wr(inst[2]),
    .in_data(Q_xmem),
    .psum_accum_in(Q_pmem),
    .accum(inst[33]), 
    .ofifo_rd(inst[6]),
    .ofifo_valid(ofifo_valid),
    .psum_out(D_pmem),
    .out_data(sfp_out),
    .relu_valid(inst[34])

);


endmodule