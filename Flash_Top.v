`include "Defines.v"

//                Top Module                       //     
// To be integrated with the FLASH Memory //
module Flash_Top (clk_i,                                // Input Ports //
                  rst_i,
                  avl_mm_slave_addr_i,
                  avl_mm_slave_data_i,
                  avl_mm_slave_write,
                  avl_mm_slave_read,
                  avl_mm_slave_byteenable_i,
                  avl_mm_slave_waitrequest_o,
                  avl_mm_mem_RY_BYn_i,                //Ready_busy input to the slave
                  avl_mm_slave_data_o,
                  avl_mm_slave_IRQ_o,
                  DQ_data,                                                                                        //-------------------------------------------------------------------------------------------------------------------
                  DQ15_A_1,                           // Bi-directional data signal          //                                           --------------------------------------------------------------------------------
                  Cen,                                   // Output signals to drive the Memory //
                  Wen,
                  Oen,
                  BYTen,
                  RStn,
                  addr);
  
  wire [15:0] avl_mm_mem_DQdata_top;          //Wired Signals to bring all the modules at the Top Module.
  wire [15:0] avl_mm_mem_other_addr_top;
  wire [6:0]  avl_mm_mem_block_addr_top;
  wire [3:0]  avl_mm_mem_code_top;
  wire [3:0]  avl_mm_mem_code_cntrl_i;
  wire [6:0]  avl_mm_mem_block_addr_cntrl_i;
  wire [15:0] avl_mm_mem_data_cntrl_i;
  wire [15:0] avl_mm_mem_other_addr_cntrl_i;
  wire [6:0]  cntrl_state_o_cntrl;
  wire cnt_done_cntrl_i;
  wire byte;
  wire clk_i_timing;
  wire rst_i_timing;
  wire [15:0] data_read_cntrl;
  wire [15:0] data_rx;
  wire [`ADDRESS_WIDTH-1:0] address_i_timing;
  wire  ack_timing_o;
  wire  ry_by;
  wire [`CONTROL_FSM_STATE_WIDTH-1:0] cntrl_op_timing_i;
  wire [`COMMAND_OP_CYCLES-1:0] cmd_op_cycles_timing_i;
  wire [`DATA_WORD_WIDTH-1:0] data_o_timing;

  wire [15:0] read_data_i; //-----------------------------------------------------------------------------
  wire [15:0] write_data_o;  //-----------------------------------------------------------------------------
  wire data_i_enable;            //--------------------------------------------------------------------------------
  wire data_o_enable;            // ---------------------------------------------------------------------------------
  wire avl_mm_mem_x8_lsb_address;//----------------------------------------------------------------------
  wire signal_drive;
  wire signal_drives;
  wire signals_drive;
  wire CEN;
  wire OEN;
  wire WEN;
  wire [22:0]ADDRESS;
  wire str;
  
// Input and Output Signal List //
  input wire clk_i;
  input wire rst_i;
  input wire [3:0] avl_mm_slave_addr_i;
  input wire [15:0] avl_mm_slave_data_i;
  input wire avl_mm_slave_write;
  input wire avl_mm_slave_read;
  output wire [15:0] avl_mm_slave_data_o;
  input wire avl_mm_slave_byteenable_i;
  output wire avl_mm_slave_waitrequest_o;
  output wire [1:0] avl_mm_slave_IRQ_o;
  input  wire avl_mm_mem_RY_BYn_i;
  inout  wire [`DATA_WORD_WIDTH-2:0] DQ_data;                             //-----------------------------------------------------------------------------
  inout wire  DQ15_A_1;                                                               //-------------------------------------------------------------
  output wire Oen;
  output wire  Cen;
  output wire  Wen;
  output wire  BYTen;
  output wire  RStn;
  output wire  [`ADDRESS_WIDTH-1:0] addr;




            assign      Cen = signal_drive ? CEN : 1'bz;
            assign      Oen = signal_drive ? OEN : 1'bz;
            assign      Wen = signal_drives ? WEN : 1'bz;
            assign      addr = signals_drive ? ADDRESS : 23'bz;
            
            assign      DQ_data = data_o_enable ? ( avl_mm_slave_byteenable_i ?  write_data_o : { 7'bzz , write_data_o[14:8] }) :  15'bzz  ;                      //-----------------------------------------------------------------------------------------------------
            assign      DQ15_A_1 = data_o_enable ? ( avl_mm_slave_byteenable_i ?  write_data_o[15] : avl_mm_mem_x8_lsb_address  )  : 1'bz;       // ------------------------------------------------------------------------------------------

            assign      read_data_i [`DATA_WORD_WIDTH-2:0] = data_i_enable ?  DQ_data [`DATA_WORD_WIDTH-2:0] : 15'bzz ;           //  -----------------------------------------------------------------------------------
            assign      read_data_i [15] = data_i_enable ? DQ15_A_1 : 1'bz ;                        //  ----------------------------------------------------------------------------------------------------------------------------
  
  // Instantiating Avalon Module within FLASH TOP input //
  avalon_slave a1 (  .clk_i(clk_i),
                     .rst_i(rst_i),
                     .avl_mm_slave_addr_i(avl_mm_slave_addr_i),
                     .avl_mm_slave_data_i(avl_mm_slave_data_i),
                     .avl_mm_slave_write(avl_mm_slave_write),
                     .avl_mm_slave_read(avl_mm_slave_read),
                     .ack(ack_timing_o),
                     .avl_mm_slave_byteenable_i(avl_mm_slave_byteenable_i),
                     .avl_mm_slave_waitrequest_o(avl_mm_slave_waitrequest_o),
                     .avl_mm_slave_data_o(avl_mm_slave_data_o),
                     .avl_mm_mem_DQdata_o(avl_mm_mem_DQdata_top),
                     .avl_mm_slave_IRQ_o(avl_mm_slave_IRQ_o),
                     .avl_mm_slave_readdata_i(read_data_i),
                     .avl_mm_mem_RY_BYn_i(avl_mm_mem_RY_BYn_i),
                     .avl_mm_mem_other_addr_o(avl_mm_mem_other_addr_top),
                     .avl_mm_mem_block_addr_o(avl_mm_mem_block_addr_top),
                     .avl_mm_mem_code_o(avl_mm_mem_code_top),
                     .avl_mm_mem_x8_lsb_address(avl_mm_mem_x8_lsb_address),
                     .start(str));
  
  // Instantiating Control FSM  Module within FLASH Top module and with avalon slave module //
  cntrl_fsm c1 ( .clk_i(clk_i),
                 .rst_i(rst_i),
                 .avl_mm_mem_block_addr(avl_mm_mem_block_addr_top),
                 .avl_mm_mem_other_addr(avl_mm_mem_other_addr_top),
                 .avl_mm_mem_wrdata(avl_mm_mem_DQdata_top),
                 .avl_mm_mem_code(avl_mm_mem_code_top),
                 .byteenable(avl_mm_slave_byteenable_i),
                 .cntrl_state_o(cntrl_state_o_cntrl),
                 .cntrl_o(cntrl_op_timing_i),
                 .cmd_cycle(cmd_op_cycles_timing_i),
                 //.data_read(data_read_cntrl),
                 //.data_read_avalon(data_rx),
                 .BYTE(byte),
                 .inner_address(address_i_timing),
                 .DQ_buf(data_o_timing),
                 .cnt_done(ack_timing_o),
                 .start1(str));

  // Instantiating Timing FSM  Module within FLASH Top module and with avalon slave module and Control FSM module //
  timing_fsm t1 (.clk_i(clk_i),
                 .rst_i(rst_i),
                 .address(address_i_timing),
                 .cntrl_op(cntrl_op_timing_i),
                 .cmd_op_cycles(cmd_op_cycles_timing_i),
                 .wrdata(data_o_timing),
                 .ack(ack_timing_o),
                 .byteenable(byte),
                 //.read_data_i(read_data_i),            // -------------------------------------------------------------
                 //.data_read(data_read_cntrl),
                 .RY_BYn(ry_by),
                 .CEn(CEN),
                 .WEn(WEN),
                 .OEn(OEN),
                 .BYTEn(BYTen),
                 .RSTn(RStn),
                 .write_data_o(write_data_o), //-------------------------------------------------------------------------
                 .ADDR(ADDRESS),
                 .data_i_enable(data_i_enable),           // ------------------------------------------------------------
                 .data_o_enable(data_o_enable),
                 .signal_drive(signal_drive),
                 .signal_drives(signal_drives),
                 .signals_drive(signals_drive));        // -----------------------------------------------------------------------
endmodule