module FF (clk, reset, en, d, q);

  parameter bw = 4;
  parameter rst_val = 1'b0;

  input clk;
  input reset;
  input en;
  input  [bw-1:0] d;
  output [bw-1:0] q;

  reg [bw-1:0] temp;
  always @ (posedge clk) begin
    if (reset) begin
      temp <= {bw{rst_val}};
    end
    else if (en) begin
      temp <= d;
    end
  end
  assign q = temp;

endmodule
