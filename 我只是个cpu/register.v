//指令寄存器
`timescale 1ns/1ns
module register(data,ena,clk,rst,opc_iraddr);
output [15:0] opc_iraddr;
input clk,rst,ena;
input [7:0]data;
reg [15:0] opc_iraddr;
reg state;
always@(posedge clk)
begin
    if (rst)
        begin
            opc_iraddr<=16'h0;
            state<=0;
        end
    else
        begin
        if(ena)
        begin
            casex(state)
            1'b0:begin
                opc_iraddr[15:8]<=data;
                state<=1;
                end
            1'b1:begin
                opc_iraddr[7:0]<=data;
                state<=0;
                end
            default:begin
                opc_iraddr[15:0]<=16'hx;
                state<=1'bx;
                end
            endcase
        end
        else
            state<=1'b0;
        end
end
endmodule




