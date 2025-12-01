// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array (clk, reset, out_s, in_w, in_n, inst_w, valid, sel_mode, flush, flush_out);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  input  [row*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;
  output [col-1:0] valid;
  input  sel_mode; // 1'b0 for weight stationary and 1'b1 for output stationary
  input  flush; 
  output [psum_bw*col-1:0] flush_out;


  reg    [2*row-1:0] inst_w_temp;
  wire   [psum_bw*col*(row+1)-1:0] temp;
  wire   [row*col-1:0] valid_temp;
  reg    [7:0] flush_temp;
  wire   [psum_bw*col-1:0] psum_array [0:7];

  genvar i;
 
  assign out_s = temp[psum_bw*col*(row+1)-1:psum_bw*col*row];
  assign temp[psum_bw*col-1:0] = in_n;
  assign valid = valid_temp[row*col-1:row*col-col];

  for (i=1; i < row+1 ; i=i+1) begin : row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw)) mac_row_instance (
         .clk(clk),
         .reset(reset),
	 .in_w(in_w[bw*i-1:bw*(i-1)]),
	 .inst_w(inst_w_temp[2*i-1:2*(i-1)]),
	 .in_n(temp[psum_bw*col*i-1:psum_bw*col*(i-1)]),
         .valid(valid_temp[col*i-1:col*(i-1)]),
	 .out_s(temp[psum_bw*col*(i+1)-1:psum_bw*col*(i)]),
         .sel_mode(sel_mode),

	 .psum_val(psum_array[i-1])
      );
  end

  // define flush out
  assign flush_out =    (flush_temp[7]==1'b1) ? psum_array[7]:
	  		(flush_temp[6]==1'b1) ? psum_array[6]:
	  		(flush_temp[5]==1'b1) ? psum_array[5]:
	  		(flush_temp[4]==1'b1) ? psum_array[4]:
	  		(flush_temp[3]==1'b1) ? psum_array[3]:
	  		(flush_temp[2]==1'b1) ? psum_array[2]:
	  		(flush_temp[1]==1'b1) ? psum_array[1]:
	  		(flush_temp[0]==1'b1) ? psum_array[0]: {(psum_bw*col){1'b0}};


  always @ (posedge clk) begin
    if (reset) begin
      inst_w_temp <= 16'd0;
      flush_temp  <= 8'd0;
    end
    else begin

      //valid <= valid_temp[row*col-1:row*col-8];
      inst_w_temp[1:0]   <= inst_w; 
      inst_w_temp[3:2]   <= inst_w_temp[1:0]; 
      inst_w_temp[5:4]   <= inst_w_temp[3:2]; 
      inst_w_temp[7:6]   <= inst_w_temp[5:4]; 
      inst_w_temp[9:8]   <= inst_w_temp[7:6]; 
      inst_w_temp[11:10] <= inst_w_temp[9:8]; 
      inst_w_temp[13:12] <= inst_w_temp[11:10]; 
      inst_w_temp[15:14] <= inst_w_temp[13:12]; 

      flush_temp[0] <= flush;
      flush_temp[1] <= flush_temp[0];
      flush_temp[2] <= flush_temp[1];
      flush_temp[3] <= flush_temp[2];
      flush_temp[4] <= flush_temp[3];
      flush_temp[5] <= flush_temp[4];
      flush_temp[6] <= flush_temp[5];
      flush_temp[7] <= flush_temp[6];
    end
  end



endmodule
