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
    output [psum_bw * col - 1 : 0] out_data
);
    parameter bw = 4;
    parameter psum_bw = 16;
    parameter col = 8;
    parameter row = 8;

    //MAC
    wire [psum_bw * col - 1 : 0]mac_out;
    wire [col - 1 : 0] mac_out_valid;
    wire [bw * col - 1 : 0] mac_in_n, mac_in_w;
    // assign mac_in_n = (inst[0])? l0_out : 0;
    // assign mac_in_w = (inst[1])? l0_out : 0;
    assign mac_in_w = l0_out;
    //L0 FIFO
    wire [bw * row - 1 : 0] l0_out;
    
    //OFIFO
    wire [psum_bw * col - 1 : 0] ofifo_out;

    //N

    mac_array #(.bw(bw), .psum_bw(psum_bw), .col(col), .row(row)) mac_array_inst(
        .clk(clk), 
        .reset(reset),
        .out_s(mac_out),
        .in_w(mac_in_w),
        .in_n(128'b0),
        .inst_w(inst[1:0]),
        .valid(mac_out_valid)
        );
    l0 #(.bw(bw)) l0_inst (
        .clk(clk),
        .reset(reset), 
        .in(in_data), 
        .out(l0_out), 
        .rd(l0_rd),
        .wr(l0_wr), 
        .o_full(), 
        .o_ready()
        );
    ofifo #(.col(col), .psum_bw(psum_bw)) ofifo_inst(
        .clk(clk),
        .reset(reset),
        .in(mac_out),
        .out(psum_out),
        .rd(ofifo_rd),
        .wr(mac_out_valid),
        .o_full(),
        .o_ready(),
        .o_valid(ofifo_valid)
        );
genvar i;
for (i = 0; i < col; i = i + 1)begin
    sfu #(.psum_bw(psum_bw)) sfu_inst(
        .clk(clk),
        .rst(reset),
        .in_valid(accum), // When valid == 1, data transfer into SFU. 
        .in(psum_accum_in[psum_bw * (i + 1) - 1 : psum_bw * i]),
        .out(out_data[psum_bw * (i + 1) - 1 : psum_bw * i])
    );
end


endmodule
