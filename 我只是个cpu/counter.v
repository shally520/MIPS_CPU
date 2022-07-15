
//程序计数器
module counter (pc_addr,ir_addr,load,clk,rst);
output [12:0]pc_addr;
input [12:0]ir_addr;
input load,clk,rst;
reg[12:0]pc_addr;
always@(posedge clk,negedge rst)
    begin
        if(rst)
            pc_addr<=13'b0_0000_0000_0000;
        else
            if(load)
            pc_addr<=ir_addr;
        else
            pc_addr<=pc_addr+1;
    end

endmodule //counter