`timescale 1ns/1ns

// Defined values for TIMING FSM //
`define  CONTROL_FSM_STATE_WIDTH 4
`define  ADDRESS_WIDTH 23
`define  COMMAND_OP_CYCLES 3
`define  DATA_WORD_WIDTH 16
`define  WORD_range 14:0
`define  BYTE_range 14:8
`define  WORD_MSB 15
`define  IDLE    4'b1001
`define  RESET 4'b0001
`define  READ 4'b0010
`define  PROGRAM 4'b0011
`define  CHIP_ERASE 4'b0100
`define  BLOCK_ERASE 4'b0101
`define  ERASE_SUSPEND 4'b0110
`define  ERASE_RESUME 4'b1000
`define  FLASH_DEVICE_IDLE 4'b1100

// Defined values for CONTROL FSM //
`define idle 7'h0
`define  reset   7'h1
`define  Read_0   7'h2
`define  Read_1   7'h3
`define  program_0   7'h5
`define  program_1   7'h6
`define  program_2   7'h7
`define  program_3   7'h8
`define  chip_erase_0  7'h9
`define  chip_erase_1  7'h10
`define  chip_erase_2  7'h11
`define  chip_erase_3  7'h12
`define  chip_erase_4  7'h13
`define  chip_erase_5  7'h14
`define  block_erase_0  7'h15
`define  block_erase_1  7'h16
`define  block_erase_2  7'h17
`define  block_erase_3  7'h18
`define  block_erase_4  7'h19
`define  block_erase_5  7'h20
`define  erase_suspend  7'h21
`define  erase_resume   7'h22
`define  idle_1   7'h23