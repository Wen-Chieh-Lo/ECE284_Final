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

// for acc
always @ (posedge clk or posedge rst) begin
  if (rst) begin
    psum <= {psum_bw{1'b0}};
  end
  else if (acc_valid) begin
    psum <= psum + in;
  end
end


// final muxing
assign out = (relu_valid && psum[psum_bw-1]) ? 0 : psum;

endmodule
