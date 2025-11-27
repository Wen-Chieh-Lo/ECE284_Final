module core  (
	input clk,
    input reset,
	input [50:0] inst, // for output stationary, extend inst to [50:0] from [33:0]
	output ofifo_valid,
    input [bw*row-1:0]  D_xmem, 
    output [psum_bw*col-1 : 0 ] sfp_out,
    input [bw*row-1:0] D_wmem
); 
    parameter bw  = 8;
    parameter col = 8;
    parameter psum_bw = 16;
    parameter row = 4;


wire [31:0] Q_xmem;
sram_32b_w2048 #(.num(2048)) input_mem(
    .CLK(clk),
    .WEN(inst[18]),
    .CEN(inst[19]),
    .D(D_xmem),
    .A(inst[17:7]),
    .Q(Q_xmem)
);

wire [31:0] Q_wmem;
sram_32b_w2048 #(.num(2048)) weight_mem(
    .CLK(clk),
    .WEN(inst[49]),
    .CEN(inst[50]),
    .D(D_wmem),
    .A(inst[48:38]),
    .Q(Q_wmem)
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

    // for output stationary,,
    .sel_mode(inst[34]),
    .relu_valid(inst[35]),
    .wmem_out(Q_wmem),
    .ififo_rd(inst[36]),
    .ififo_wr(inst[37])
);


endmodule
