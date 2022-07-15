//地址多路器
module adr (addr,pc_addr,ir_addr,fetch);
output [12:0]addr;
input [12:0]pc_addr,ir_addr;
input fetch;
assign addr = fetch?pc_addr:ir_addr;


endmodule //adr