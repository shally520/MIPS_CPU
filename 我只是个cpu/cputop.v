`include "cpu.v"
`include "perip/ram.v"
`include "perip/rom.v"
`include "perip/addr_decode.v"

`timescale 1ns/1ns
`define PERIOD 100
module cputop;
reg reset_req,clock;
integer test;
reg[3*8:0] mnemonic;
 