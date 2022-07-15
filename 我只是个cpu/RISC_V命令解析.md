## 基本指令格式
4种核心指令格式（R/I/S/U）,都是固定32位长度的指令。基于立即数的处理，还有SB/UI这两种指令格式的变种。
CPU包含32个通用寄存器，x0-x31
PC程序寄存器，PC的宽度和通用寄存器的宽度一样
XLEN就是有多少个寄存器，一般等于RISC-V CPU架构
RV32I可被分为六种基本指令格式
```
1.用于寄存器-寄存器操作的R类型指令
2.用于立即数和访存load操作的I型指令
3.用于访存store操作的S型指令
4.用于条件跳转操作的B型指令
5.用于长立即数的U型指令
6.用于无条件跳转的J型指令
```
opcode决定指令的大致分类，funct3和funct7决定指令更细致的分类
RISC-V只支持小端格式地址排序
```
0x0A0B0C0D
小端的最高位字节是0X0A,最低位字节是0X0D
大端的最高位字节是0X0D,最低位字节是0X0A
```

## L type inst
RV32I中只有load和store指令可以访问储存器，其他指令只能操作寄存器。

1. LW LW rd,offset(rs1) x[rd] = sext(M[x(rs1)]+sext(offset)][31:0])将32位值复制到rd中，(offset是个数)
2. LH LH rd,offset(rs1).x[rd] = sext(M[x(rs1)]+sext(offset)][15:0])从储存器中读取16位，然后将其符号位扩展到32位，保存到rd中。
3. LHU LHU rd,offset(rs1). 该指令读取存储器16位，然后0扩展到32位，再保存到rd中。
4. LB LB rd,offset(rs1).x[rd] = sext(M[x(rs1)]+sext(offset)][7:0]),该指令从有效地址中读取一个字节byte，经符号位扩展后写入rd寄存器。
5. LBU 经零扩展后写入rd寄存器
## R type inst(10条) over
bit7-11是rd的索引号，rd寄存器是用来存储结果的寄存器，rs1和rs2是源寄存器

1. ADD ADD rd,rs1,rs2. x[rd] = x[rs1]+x[rs2],该指令将rs1+rs2的结果写入rd中。ADD和SUB差一位不同
2. SLT SLT rd,rs1,rs2. x[rd] = x[rs1]<x[rs2]，该指令将rs1和rs2当作有符号数进行比较，如果rs1<rs2 rd置1.否则置0.
3. SLTU SLTU rd,rs1,rs2. x[rd] = x[rs1]<x[rs2],该指令将rs1和rs2当作无符号数进行比较，如果rs1<rs2 rd置1.否则置0.
4. AND AND rd,rs1,rs2.x[rd] = x[rs1]&x[rs2](逐位相与)，OR逐位相或，XOR按位异或
5. SLL 逻辑左移 SLL rd,rs1,rs2.x[rd] = x[rs1]<<x[rs2],该指令将rs1左移rs2位，空出来的位置填0，结果写入rd寄存器。rs2寄存器中低五位为有效移动位数，其高位可忽略。SRL逻辑右移。
6. SRL 逻辑右移 SRL rd, rs1,rs2.x[rd] = x[rs1]>>x[rs2]，该指令将rs1右移rs2位，空出的位置填0，结果写入rd寄存器，rs2中低五位有效
6. SRA 算术右移 SRA rd,rs1,rs2. x[rd] = x[rs1]>>x[rs2],该指令将rs1右移rs2位空出来的位置由rs1寄存器值中的最高位rs1[31]填充，结果写入rd寄存器。rs2寄存器中低五位为有效移动位数，其高位可忽略。
7. SUB SUB rd,rs1,rs2.x[rd] = x[rs1]-x[rs2],该指令将rs1-rs2结果写入rd中。
## I type inst(15条) over
bit20-31是一个立即数

1. ADDI ADDI
``` 
    rd,rs1,imm.把rs1寄存器中的值和有符号位扩展的立即数相加，之后把相加得到的结果存到rd中。(立即数加法)
```
2. SLTI(set less than imm)
```
    SLTI rd,rs1,imm. if(rs1<imm) rd=1; else rd=0; 其中rs1和imm都被当作有符号数。置为条件LT
```
3. SLTIU 
```
    同上，不过rs1和imm被当作无符号数。SLTIU rd,rs1,imm.(有符号位和无符号为进行比较区别)，将立即数有符号扩展，当作无符号数进行比较后置位
```
4. ANDI ANDI rd,rs1,imm.x[rd]=x[rs1]&sext(imm) ORI、XORI均为逻辑操作，在寄存器rs1和符号扩展位上的12bit按位AND、OR、XOR。

5. 剩下的移位指令，将立即数imm分为两个部分，12bit立即数分为imm[11:5]中的imm[10](bit30)用来区分移位类型，其中SLLI和SRLI指令机器码的bit30为0，而SRAI指令机器码的bit30为1.imm[4:0]为移位量，在RV32I中最大移位量是31位，也就是2^5-1
6. SLLI 立即数逻辑左移指令 SLLI rd,rs1,shamt.x[rd]=x[rs1]<<shamt,该指令将rs1中的值左移shamt[4:0]，rs1的低位补零，结果写入rd中。
7. SRLI 立即数逻辑右移指令 SRLI rd,rs1,shamt.x[rd]=x[rs1]>>shamt,该指令将rs1中的值右移shamt[4:0]位，rs1的高位补零，结果写入rd中。
8. SRAI 立即数算术右移指令 SRAI rd,rs1,shamt.x[rd]=x[rs1]>>shamt,该指令将rs1中的值右移shamt[4:0]位，rs1的高位由原rs1[31]填充，结果写入rd中。.SRLI和SRAI ins[30]位不同
## S type inst
没有rd寄存器，该类指令将立即数分成两个部分，imm[11:5]在bit25-31即占用funct7的位置，imm[4:0]在bit7-11即占用了rd的位置，说明该指令不需要回写

1. SW SW rs2,offset(rs1),M[x(rs1)]+sext(offset)] = x[rs2][31:0],该指令将rs2寄存器中四个字节存入有效地址
2. SH SH rs2,offset(rs1),M[x(rs1)]+sext(offset)] = x[rs2][15:0]
3. SB SB rs2,offset(rs1),M[x(rs1)]+sext(offset)] = x[rs2][7:0]
## B type inst over
跳转指令，带条件跳转

1. BEQ 相等时分支，BEQ rs1,rs2,offset. if (rs1 == rs2)pc+=sext(offset),BNE 不相等时分支
2. BLT 小于时分支(有符号)，BLT rs1,rs2,offset. if (rs1<rs2) pc+=sext(offset),BLTU 无符号小于时分支
3. BGE 大于等于时分支(有符号)，BGEU大于等于时分支(无符号数)
## U type inst
提供20位立即数bit31-12，最后运算的结果与20位立即数相关，并把结果回写到rd寄存器

1. LUI 高位立即数加载指令 LUI rd,imm. x[rd]=sext(imm[31:12]<<12)，该指令把upper-imm写入rd的高20位，rd的低12位补零。
2. AUIPC PC加立即数指令 AUIPC rd,imm. x[rd]=pc+sext(imm[31:12]<<12),该指令将20位的立即数符号扩展后，左移12位，和当前PC相加，结果写入rd寄存器中
## J type inst over

1. JAL JAL rd,offset. x[rd] = pc+4;pc+ = sext(offset),该指令把下一条指令的地址(pc+4)存入rd寄存器中，然后把PC设置为当前值加上符号位扩展的偏移量
2. JALR 间接跳转指令，JALR rd,offset(rs1),该指令将pc设置为rs1寄存器中的值加上符号位扩展的偏移量，把计算出地址的最低有效位设为0，并将原pc+4的值写入rd寄存器。如果不需要目的寄存器，可以将rd设置为x0

17. AUIPC+JALR可以将控制转移到任意32位相对地址，而加上一条12位立即数偏移的load/store指令就可以访问任意32位pc相对数据地址。
18. NOP此指令不改变任何用户的可见状态，用于pc的向前推进。 被编码为 ADDI x0,x0,0

22. 其他的如 BGT/BGTU/BLE/BLEU可以通过前面的比较指令组合来实现。
## CSR inst
csr是一类扩展寄存器，控制和状态寄存器，一类是寄存器操作：CSRRW.CSRRS.CSRRC.一类是立即数操作CSRREI,CSRRSI,CSRRCI

1. CSRRW(Atomic Read/write CSR) CSRRW rd,csr,rs1,把CSR寄存器中的值读出并赋值到rd寄存器中。再把rs1寄存器中的值写入CSR寄存器中"CSRRW rd ,csr,rs1"
2. CSRRS(Atomic Read and Set Bits in CSR) CSRRS rd,csr,rs1 ,把csr寄存器中的值读出并赋值到rd寄存器中，且将csr寄存器中的值和寄存器rs1中的值按位或的结果写入csr寄存器
3. CSRRC(Atomic Read and Clear Bits in CSR)CSRRC rd,csr,rs1 ,把csr寄存器中的值读出并赋值到rd寄存器中，且将csr寄存器中的值和寄存器rs1中的值取反后按位与的结果写入csr寄存器
4. CSRRWI 把csr寄存器中的值读出并赋值到rd寄存器中，再把五位的零扩展(高位扩展为0)的立即数zimm写入csr寄存器"CSRRWI rd ,csr .zimm[4:0]"
5. CSRRSI 把csr寄存器中的值读出并赋值到rd寄存器中，且将csr寄存器中的值和五位的0扩展的立即数zimm按位或的结果写入csr寄存器
6. CSRRCI 把csr寄存器中的值读出并赋值到rd寄存器中，且将csr寄存器中的值和五位的0扩展的立即数zimm取反后按位与的结果写入csr寄存器
读取CSR的汇编伪指令 CSRR 被编码为 CSRRS rd,csr,x0
写入CSR的汇编位指令 CSRW 被编码为CRSRW x0,csr,rs1
伪指令 CSRWI csr,zimm 被编码为 CSRRWI x0,csr,zimm
当不需要CSR旧值时, 同来设置和清除CSR中的位 CSRS/CSRC csr,rs1 CSRSI/CSRCI csr,zimm
## M type inst
1. MUL执行一次两个XLEN位的带符号乘法rs1×rs2，并将结果的低XLEN存到rd中，忽略溢出。
2. MULH、MULHU、MULHSU执行相同的乘法，分别针对的对象为有符号×有符号、无符号×无符号、 有符号×无符号乘法，并将运算结果2×XLEN位中的高XLEN位返回。
如果同时需要结果的高、低XLEN位，一般代码顺序为：
MULH[[S]U] rdh,rs1,rs2 ;
MUL rdl,rs1,rs2;
3. DIV/DIVU分别做带符号和无符号的整数除法，REM/REMU分别做带符号和无符号的取余。除法指令有两条
4. 如果同时要商和余数，建议代码为
DIV[U] rdq,rs1,rs2;
REM[U] rdq,rs1,rs2;
参考链接1 http://www.icfedu.cn/archives/5282
参考链接2 https://blog.csdn.net/New_Horizon_/article/details/90314049?spm=1001.2014.3001.5502
## 流水线
五级流水线包括，取指，译码，执行，访存，写回
 - 取指阶段：从指令存储器读出指令，同时确定下一条指令地址。
 - 译码阶段：对指令进行译码，从通用寄存器中读出要使用的寄存器的值，如果指令中含有立即数，那么还要将立即数进行符号扩展或无符号扩展。如果是转移指令，并且满足转移条件，那么给出转移目标，作为新的指令地址。
 - 执行阶段：按照译码阶段给出的操作数、运算类型，进行运算，给出运算结果。如果是Load/Store指令，那么还会计算Load/Store的目标地址。
 - 访存阶段：如果是Load/Store指令，那么在此阶段会访问数据存储器，反之，只是将执行阶段的结果向下传递到回写阶段。同时，在此阶段还要判断是否有异常需要处理，如果有，那么会清除流水线，然后转移到异常处理例程入口地址处继续执行。
 - 回写阶段：将运算结果保存到目标寄存器。



