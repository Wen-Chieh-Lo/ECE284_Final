// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset, mode);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; 
output [bw-1:0] out_e; 
input  [1:0] inst_w; // inst[1]:execute, inst[0]: kernel loading, inst[2]: even kernel load, inst[3]: odd kernel load
output [1:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;
input mode;

reg [1:0]inst_q;
reg [bw-1:0]a_q;
reg [bw-1:0]b_q;

reg [bw-1:0]b_q_even;
reg [bw-1:0]b_q_odd;

reg [psum_bw-1:0]c_q;
reg load_ready_q;
wire [psum_bw - 1 : 0] mac_out;

reg load_phase; //0: even 1:odd

assign out_e = a_q;
assign inst_e = inst_q;
assign out_s = mac_out;

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b_even(b_q_even),
        .b_odd(b_q_odd),
        .c(c_q),
	.out(mac_out),
        .mode(mode)
); 

always @(posedge clk)begin
        if(reset)begin
                inst_q <= 0;
                load_ready_q <= 1;
                a_q <= 0;
                b_q_even <= 0;
                b_q_odd <= 0;
                c_q <= 0;
                load_phase <= 0;
        end
        else begin
                if(inst_w)begin
                        a_q <= in_w;
                end
                else begin
                        a_q <= a_q;
                end
                if (mode == 1'b0) begin // 4bit mode
                        if(inst_w[0] && load_ready_q)begin
                                b_q_even <= in_w;
                                b_q_odd <= in_w;
                                load_ready_q <= 0;
                        end
                        else begin
                                b_q_even <= b_q_even;
                                b_q_odd <= b_q_odd;
                                load_ready_q <= load_ready_q;
                        end

                        if(!load_ready_q)begin
                                inst_q[0] <= inst_w[0];
                        end
                        inst_q[1] <= inst_w[1];
                        
                        c_q <= in_n;
                end
                else begin // 2bit mode
                        if(inst_w[0] && load_ready_q)begin
                                if (load_phase == 1'b0) begin
                                        b_q_even <= in_w;
                                        load_phase <= 1'b1;
                                end
                                else begin
                                        b_q_odd <= in_w;
                                        load_phase <= 1'b0;
                                        load_ready_q <= 0;
                                end
                        end
                        else begin
                                b_q_even <= b_q_even;
                                b_q_odd <= b_q_odd;
                                load_ready_q <= load_ready_q;
                                load_phase <= load_phase;
                        end

                        if(!load_ready_q)begin
                                inst_q[0] <= inst_w[0];
                        end
                        inst_q[1] <= inst_w[1];
                        
                        c_q <= in_n;
                end
        end
end

endmodule
