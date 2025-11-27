module sfu(
    input clk,
    input rst,
    input acc_valid, // When valid == 1, data transfer into SFU. Also override Relu request.
    input relu_valid,
    input signed [psum_bw-1 : 0] in,
    output signed [psum_bw-1 : 0] out
);
parameter psum_bw = 16;
reg signed [psum_bw - 1 : 0] psum;
reg signed [psum_bw - 1 : 0] relu_ff;
reg relu_valid_ff;

// for acc
always @ (posedge clk or posedge rst) begin
  if (rst) begin
    psum <= {psum_bw{1'b0}};
  end
  else if (acc_valid) begin
    psum <= psum + in;
  end
end

// for relu
always @ (posedge clk or posedge rst) begin
  if (rst) begin
    relu_ff <= {psum_bw{1'b0}};
  end
  else if (relu_valid) begin
    relu_ff <= (in[psum_bw-1]==1'b1) ? {psum_bw{1'b0}} : in;
  end
end
always @ (posedge clk or posedge rst) begin
  if (rst) begin
    relu_valid_ff <= 1'b0;
  end
  else begin
    relu_valid_ff <= relu_valid;
  end
end

// final muxing
assign out = (relu_valid_ff==1'b1) ? relu_ff : psum;

endmodule
