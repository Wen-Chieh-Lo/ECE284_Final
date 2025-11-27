// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset, sel_mode);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
output [bw-1:0] out_e; 
input  [1:0] inst_w;
output [1:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;
input  sel_mode; // 1'b0 for weight stationary and 1'b1 for output stationary


/////////////////////////
/// divide FF and comb //
/////////////////////////
// no need to be changed for output stationary
wire load_ready_q;
wire load_ready_d;  assign load_ready_d  = 1'b0;
wire load_ready_en; assign load_ready_en = ((inst_w[0]==1'b1) && (load_ready_q==1'b1));
FF #(.bw(1), .rst_val(1'b1)) FF_load_ready (.clk(clk), .reset(reset), .en(load_ready_en), .d(load_ready_d), .q(load_ready_q));

// for psum ff
wire c_en; assign c_en = 1'b1;
wire [psum_bw-1:0] c_q;
wire [psum_bw-1:0] c_d; assign c_d = (sel_mode==1'b0) ? in_n : mac_out;
FF #(.bw(psum_bw), .rst_val(1'b0)) FF_c (.clk(clk), .reset(reset), .en(c_en), .d(c_d), .q(c_q));

// for activation, no need to be changed
wire a_en;         assign a_en = (inst_w[0] || inst_w[1]);
wire [bw-1:0] a_d; assign a_d  = in_w;
wire [bw-1:0] a_q;
FF #(.bw(bw), .rst_val(1'b0)) FF_a (.clk(clk), .reset(reset), .en(a_en), .d(a_d), .q(a_q));
assign out_e = a_q;

// no need to be changed
wire [1:0] inst_q;
wire [1:0] inst_d; assign inst_d = (load_ready_q == 1'b0) ? {inst_w[1], inst_w[0]} : {inst_w[1], inst_q[0]};
wire inst_en;      assign inst_en = 1'b1;
FF #(.bw(2), .rst_val(1'b0)) FF_inst (.clk(clk), .reset(reset), .en(inst_en), .d(inst_d), .q(inst_q));
assign inst_e = inst_q;

// for weight 
wire [bw-1:0] b_q;
wire [bw-1:0] b_d; assign b_d  = (sel_mode==1'b0) ? in_w : in_n[bw-1:0];
wire b_en;         assign b_en = (sel_mode==1'b0) ? ((inst_w[0]==1'b1) && (load_ready_q==1'b1)) : (inst_w[1]==1'b1);
FF #(.bw(bw), .rst_val(1'b0)) FF_b (.clk(clk), .reset(reset), .en(b_en), .d(b_d), .q(b_q));


/////////////////////
// MODULE INSTANCE //
/////////////////////
wire [psum_bw-1:0] mac_out;
mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b(b_q),
        .c(c_q),
	.out(mac_out)
); 
assign out_s = (sel_mode==1'b0) ? mac_out : {{(psum_bw-bw){1'b0}}, b_q};

endmodule
