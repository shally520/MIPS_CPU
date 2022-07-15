## 不知道取什么标题就随便
1. 首先你要有GNU工具链，这个我买了，等会上传
2. 新建一个汇编文件例如:inst_rom.S
    ```
    .org 0x0
    .global _start
    .set noat
    _start:
    ori $1,$0,0x1100
    ori $2,$0,0x0020
    ori $3,$0,0xff00
    ori $4,$0,0xffff

    ```
3. 生成inst_rom.o
    ```
    mips-sde-elf-as –mips32 inst_rom.S –o inst_rom.o
    ```
4. 新建文件ram.ld
    ```
    MEMORY
    {
    ram : ORIGIN = 0x00000000, LENGTH = 0x00001000
    }

    SECTIONS
    {
    .text :
        {
        *(.text)
        }>ram
        
        .data :
        {
        *(.data)
        }>ram
        
        .bss :
        {
        *(.bss)
        }>ram
    }

    ```
5. 生成inst_rom.om
    ```
    mips-sde-elf-ld –T ram.ld inst_rom.o –o inst_rom.om
    ```
6. 生成inst_rom.bin
    ```
    mips-sde-elf-objcopy –O binary inst_rom.om inst_rom.bin
    ```
7. 生成inst_rom.data
    ```
    ./Bin2Mem.exe –f inst_rom.bin –o inst_rom.data
    ```
8. 生成的二进制文件我们看不到怎么办
    ```
    mips-sde-elf-objdump -D inst_rom.om > inst_rom.asm
    ```