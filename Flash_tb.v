`include "Defines.v"


module flash_tb();
  reg clk_i;                
  reg rst_i;
  reg [3:0] avl_mm_slave_addr_i;                  
  reg [15:0] avl_mm_slave_data_i;
  reg avl_mm_slave_write;
  reg avl_mm_slave_read;
  reg avl_mm_slave_byteenable_i;
  wire wait_request;
  wire [15:0] data_o;
  wire [1:0] IRQ;
  //wire Ry_By_o;
  wire RB;
  wire Cen;
  wire Wen;
  wire RStn;
  wire Oen;
  wire BYTen;
  wire [22:0] addr;
  wire [14:0] DQ;  
  wire DQ15_A_1;
  wire signal_drive;
  
  //Signals to be driven high z from testbench
  wire WEn_tb;
  wire CEn_tb;
  wire OEn_tb;
  wire [22:0] addr_tb;
  wire BYTEn_tb;
  //wire DQ15_A_1_tb;
  //wire [14:0] DQ_tb;
  
  //Signal to help the signals go to high z
  //reg drive_tb;
  //reg output_en;
  
  //Power Up signals
  reg [35:0]VCC;
  reg [35:0]VCCQ;
  reg info;
  reg [35:0]VPP;
                                   
 
  Flash_Top f1 (.clk_i(clk_i),
                  .rst_i(rst_i),
                  .avl_mm_slave_addr_i(avl_mm_slave_addr_i),
                  .avl_mm_slave_data_i(avl_mm_slave_data_i),
                  .avl_mm_slave_write(avl_mm_slave_write),
                  .avl_mm_slave_read(avl_mm_slave_read),
                  .avl_mm_slave_byteenable_i(avl_mm_slave_byteenable_i),
                  .avl_mm_slave_waitrequest_o(wait_request),
                  .avl_mm_slave_data_o(data_o),
                  .avl_mm_slave_IRQ_o(IRQ),
                  .avl_mm_mem_RY_BYn_i(RB),
                  .Cen(Cen),
                  .Wen(Wen),
                  .Oen(Oen),
                  .RStn(RStn),
                  .BYTen(BYTen),
                  .DQ_data(DQ),
                  .DQ15_A_1(DQ15_A_1),
                  .addr(addr));  

 mt28ew uut(.A(addr), .DQ(DQ), .DQ15A_1(DQ15_A_1), .E_N(Cen), .G_N(Oen), .W_N(Wen), .RP_N(RStn), .RB_N(RB), .BYTE_N(BYTen), .VCC(VCC), .VCCQ(VCCQ), .VPP(VPP), .Info(info));
  //mt28ew uut(addr, DQ[14:0],DQ[15],Cen,Oen,Wen,RStn, Ry_By_o,BYTen,VCC,VCCQ,VPP,info);
 
  initial
    begin
      clk_i = 1'b1;
      forever #5 clk_i = ~clk_i;
    end
  
  //Let TB drive the signals to high Z while memory is being Reset. Then Design drives to required values.
  //assign output_enable = output_en;
  //assign Cen    = (drive_tb)? 1'bz : ( (output_en ? Cen : 1'bz));
  //assign WEn_tb    = (drive_tb)? 1'bz : Wen;
 // assign OEn_tb    = (drive_tb)? 1'bz : Oen;
 // assign BYTEn_tb  = (drive_tb)? 1'bz : BYTen;
//  assign addr_tb   = (drive_tb)? 23'bz : addr;
  
  initial
    begin
      rst_i    = 1'b0;
    //  drive_tb = 1'b1;                                  //Test bench drives the signals to be asserted to memory to high Z
      VCC = 36'd02701;
      VCCQ = 36'd01651;
      VPP =  36'd02701;
      info = 1;
      avl_mm_slave_addr_i      = 0;
      avl_mm_slave_data_i      = 0;
      avl_mm_slave_write       = 0;
      avl_mm_slave_read        = 0;
      avl_mm_slave_byteenable_i  = 1'b1;

      // Sequence 
      #300000                                            // Delay of minimum 300us between VCC to CEn
      rst_i  = 1'b1;
     // drive_tb = 1'b0;                                  // Design drives the signals to be asserted to memory
      avl_mm_slave_addr_i      = 4'h1;
      avl_mm_slave_data_i      = 4'h0;
      avl_mm_slave_write       = 1'b1;
      avl_mm_slave_read        = 1'b0;
      avl_mm_slave_byteenable_i  = 1'b1;
      #10
      avl_mm_slave_addr_i      = 4'h2;
      avl_mm_slave_data_i      = 16'h127;
      avl_mm_slave_write       = 1'b1;
      avl_mm_slave_read        = 1'b0;
      #10
      avl_mm_slave_addr_i      = 4'h3;
      avl_mm_slave_data_i      = 16'hAE8;
      avl_mm_slave_write       = 1'b1;
      avl_mm_slave_read        = 1'b0;
      avl_mm_slave_byteenable_i  = 1'b1;
      #10
      avl_mm_slave_addr_i      = 4'h6;
      avl_mm_slave_data_i      = 4'h3;
      avl_mm_slave_write       = 1'b1;
      avl_mm_slave_read        = 1'b0;
      avl_mm_slave_byteenable_i  = 1'b1;
      #25800
      avl_mm_slave_addr_i      = 4'h1;
      avl_mm_slave_data_i      = 4'h0;
      avl_mm_slave_write       = 1'b1;
      avl_mm_slave_read        = 1'b0;
      avl_mm_slave_byteenable_i  = 1'b1;
      #10
      avl_mm_slave_addr_i      = 4'h2;
      avl_mm_slave_data_i      = 16'h127;
      avl_mm_slave_write       = 1'b1;
      avl_mm_slave_read        = 1'b0;
      #10
      avl_mm_slave_addr_i      = 4'h6;
      avl_mm_slave_data_i      = 4'h2;
      avl_mm_slave_write       = 1'b1;
      avl_mm_slave_read        = 1'b0;
      avl_mm_slave_byteenable_i  = 1'b1;
      #50
      avl_mm_slave_addr_i      = 4'h4;
      avl_mm_slave_write       = 1'b0;
      avl_mm_slave_read        = 1'b1;
      #1000;
    end
endmodule