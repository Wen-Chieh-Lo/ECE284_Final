module corelet(
    input clk,
    input reset,
    input [1 : 0] inst, // 1st bit : execute 0th: Load Kernel
    input l0_or_ififo,
    input l0_rd,
    input l0_wr,
    input [bw * row - 1 : 0] in_data,
    input [127:0]psum_accum_in,
    input accum,
    input ofifo_rd,
    output ofifo_valid,
    output [127:0]psum_out,
    output [psum_bw * col - 1 : 0] out_data,

    // below is for output stationary
    input sel_mode, // 0 for weight stationary, 1 for output stationary
    input relu_valid,
    input [bw * col-1:0] wmem_out, // from north, have to extend to 128bit
    input ififo_rd,
    input ififo_wr
);
    parameter bw = 4;
    parameter psum_bw = 16;
    parameter col = 8;
    parameter row = 8;

    //MAC
    wire [psum_bw * col - 1 : 0]mac_out;
    wire [col - 1 : 0] mac_out_valid;
    wire [bw*col-1:0] mac_in_w;
    wire [psum_bw*col-1:0] mac_in_n;
    wire [bw*col-1:0] ififo_out;
    assign mac_in_w = l0_out;
    assign mac_in_n = (sel_mode==1'b0) ? 128'd0 : {12'h000,ififo_out[31:28],12'h000,ififo_out[27:24],12'h000,ififo_out[23:20],12'h000,ififo_out[19:16],
	                                           12'h000,ififo_out[15:12],12'h000,ififo_out[11: 8],12'h000,ififo_out[ 7: 4],12'h000,ififo_out[ 3: 0]};
    //L0 FIFO
    wire [bw * row - 1 : 0] l0_out;
    wire float_0, float_1;
    
    //OFIFO
    wire [psum_bw * col - 1 : 0] ofifo_out;
    wire float_2, float_3;

    // IFIFO
    wire float_4, float_5;

    // make instance
    mac_array #(.bw(bw), .psum_bw(psum_bw), .col(col), .row(row)) mac_array_inst(
        .clk(clk), 
        .reset(reset),
        .out_s(mac_out),
        .in_w(mac_in_w),
        .in_n(mac_in_n),
        .inst_w(inst[1:0]),
        .valid(mac_out_valid),
	.sel_mode(sel_mode)
        );
    l0 #(.bw(bw)) l0_inst (
        .clk(clk),
        .reset(reset), 
        .in(in_data), 
        .out(l0_out), 
        .rd(l0_rd),
        .wr(l0_wr), 
        .o_full(float_0), 
        .o_ready(float_1)
        );
    ofifo #(.col(col), .psum_bw(psum_bw)) ofifo_inst(
        .clk(clk),
        .reset(reset),
        .in(mac_out),
        .out(psum_out),
        .rd(ofifo_rd),
        .wr(mac_out_valid),
        .o_full(float_2),
        .o_ready(float_3),
        .o_valid(ofifo_valid)
        );
    ififo #(.bw(bw), .col(col)) ififo_inst (
        .clk(clk),
        .reset(reset), 
        .in(wmem_out), 
        .out(ififo_out), 
        .rd(ififo_rd),
        .wr(ififo_wr), 
        .o_full(float_4), 
        .o_ready(float_5)
        );

    genvar i;
    for (i = 0; i < col; i = i + 1)begin
        sfu #(.psum_bw(psum_bw)) sfu_inst(
            .clk(clk),
            .rst(reset),
            .acc_valid(accum), // When valid == 1, data transfer into SFU. 
	    .relu_valid(relu_valid),
            .in(psum_accum_in[psum_bw * (i + 1) - 1 : psum_bw * i]),
            .out(out_data[psum_bw * (i + 1) - 1 : psum_bw * i])
        );
    end


endmodule
