//累加器用于存放当前结果
module accum (
    accum,data,ena,clk,rst
);
output[7:0] accum;
input clk,rst,ena;
input [7:0] data;
reg [7:0]accum;
always@(posedge clk)
begin
    if(rst)
    accum<=8'b00000000;
    else
    if(ena)
        accum<=data;

end
endmodule //accum