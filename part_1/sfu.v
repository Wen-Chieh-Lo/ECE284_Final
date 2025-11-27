module sfu(
    input clk,
    input rst,
    input in_valid, // When valid == 1, data transfer into SFU. Also override Relu request.
    input signed [psum_bw-1 : 0] in,
    output signed [psum_bw-1 : 0] out
);
parameter psum_bw = 16;
reg signed [psum_bw - 1 : 0] psum;
assign out = psum;

always @(posedge clk or posedge rst)begin
    if(rst)begin
        psum <= 0;
    end
    else begin
        if(in_valid)begin
            psum <= psum + in;
        end
        else begin
            psum <= psum;
        end
    end
end

endmodule