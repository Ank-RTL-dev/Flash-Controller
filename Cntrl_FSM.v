`include "Defines.v"
//           Control FSM                            //
module cntrl_fsm (clk_i,
                  rst_i,
                  cnt_done,
                  avl_mm_mem_wrdata,
                  avl_mm_mem_other_addr,
                  avl_mm_mem_block_addr,
                  avl_mm_mem_code,
                  byteenable,
                  start1,
                  cntrl_state_o,
                  cntrl_o,
                  cmd_cycle,
                  BYTE,
                  //data_read,
                  //data_read_avalon,
                  inner_address,
                  DQ_buf);
   
//          Input Ports                          //
   input clk_i;
   input rst_i;
   input cnt_done;
   input [3:0]  avl_mm_mem_code;
   input byteenable;
   input [6:0]  avl_mm_mem_block_addr;
   input [15:0] avl_mm_mem_wrdata;
   input [15:0] avl_mm_mem_other_addr;
   //input [15:0] data_read;
   input start1;

  
//         Outut Ports                         //
   output reg [6:0] cntrl_state_o;
   output reg BYTE;
   output reg [3:0] cntrl_o;
   output reg [2:0] cmd_cycle;
   output reg [22:0] inner_address;
   //output [15:0] data_read_avalon;
   output reg [15:0] DQ_buf;
 
  
//     Register Definitions                  //
   //reg start;-----
   reg [15:0] txdata;

// Assigning the signals used in Control_FSM //  
   //assign data_read_avalon = data_read;
   assign BYTE = byteenable;
  
  
//     States Shift logic                   //
   always @(posedge clk_i or posedge rst_i)
     begin
       if (rst_i == 1'b0)
         begin
           txdata        <=  0;
         end
       else
         begin
           txdata        <=  avl_mm_mem_wrdata;
         end
     end
      
//    State Machine implementations         //
   always @(posedge clk_i or posedge rst_i)
     begin
       if (rst_i == 1'b0)
         begin
           cntrl_state_o <= `idle;
           inner_address <=  0;
           DQ_buf        <=  0;
           cmd_cycle     <=  3'b0;
         end
       else
         case(cntrl_state_o)
           `idle : 
             begin
               if (start1)
                 begin
                   case(avl_mm_mem_code)
                     4'h1 : begin
                       cntrl_state_o    <= `reset;
                       cntrl_o          <= 4'b0001;                     // Code command for different commands to be executed
                     end
                     4'h2 : begin
                       cntrl_state_o    <= `Read_1;
                       cntrl_o          <= 4'b0010;
                     end
                     4'h3 : begin
                       cntrl_state_o    <= `program_0;
                       cntrl_o          <= 4'b0011;
                     end
                     4'h4 : begin 
                       cntrl_state_o    <= `chip_erase_0;
                       cntrl_o          <= 4'b0100;
                     end
                     4'h5 : begin
                       cntrl_state_o    <= `block_erase_0;
                       cntrl_o          <= 4'b0101;
                     end
                     4'h6 : begin 
                       cntrl_state_o    <= `erase_suspend;
                       cntrl_o          <= 4'b0110;
                     end
                     4'h7 : begin 
                       cntrl_state_o    <= `erase_resume;
                       cntrl_o          <= 4'b1000;
                     end
                     default : begin
                       cntrl_state_o <= `idle;
                     end
                   endcase
                 end
               else
                 cntrl_state_o <= `idle;
             end
           //    One cycle command needs to be used to reset the Flash    // 
           `reset :
             begin
               inner_address <= 0;
               DQ_buf        <= 16'hF0;
               if (cnt_done)
                 begin
                   cntrl_state_o <= `idle_1;
                 end
               else
                 begin
                   cntrl_state_o <= `reset;
                 end
             end
          //    Four  cycle command needs to be used to program the Flash    // 
           `program_0 :
              begin
                inner_address <= BYTE ? 'h555 : 'hAAA;
                DQ_buf        <= 16'hAA;
                cmd_cycle     <=  3'b001;
                if (cnt_done)
                  begin
                    cntrl_state_o <= `program_1;
                  end
                else
                  begin
                    cntrl_state_o   <= `program_0;
                  end
              end
           `program_1 :
             begin
               inner_address <=  BYTE? 'h2AA : 'h555;
               DQ_buf        <= 16'h55;
               cmd_cycle     <=  3'b010;
               if (cnt_done)
                 begin
                   cntrl_state_o <= `program_2;
                 end
               else
                 begin
                   cntrl_state_o   <= `program_1;
                 end
             end
           `program_2 :
               begin
                 inner_address <=  BYTE? 'h555 : 'hAAA;
                 DQ_buf        <= 16'hA0;
                 cmd_cycle     <=  3'b011;
                 if (cnt_done)
                   begin
                     cntrl_state_o <= `program_3;
                   end
                 else
                   begin
                     cntrl_state_o   <= `program_2;
                   end
               end
           `program_3 :
             begin
               inner_address <= { avl_mm_mem_block_addr , avl_mm_mem_other_addr };
               DQ_buf        <= txdata;
               cmd_cycle     <=  3'b100;             
               if (cnt_done)
                 begin
                   cntrl_state_o <= `idle_1;
                 end
               else
                 begin
                   cntrl_state_o   <= `program_3;
                 end
               end
           
               
          //    Six  cycle command needs to be used to erase the Flash    // 
           `chip_erase_0 :
               begin
                 inner_address <=  BYTE? 'h555 : 'hAAA;
                 DQ_buf        <= 16'hAA;
                 if (cnt_done)
                   begin
                     cntrl_state_o <= `chip_erase_1;
                   end
                 else
                   begin
                     cntrl_state_o   <= `chip_erase_0;
                   end
               end
           `chip_erase_1 :
               begin
                 inner_address <=  BYTE? 'h2AA : 'h555;
                 DQ_buf        <= 16'h55;
                 if (cnt_done)
                   begin
                     cntrl_state_o <= `chip_erase_2;
                   end
                 else
                   begin
                     cntrl_state_o   <= `chip_erase_1;
                   end
               end
           `chip_erase_2 :
               begin
                 inner_address <=  BYTE? 'h555 : 'hAAA;
                 DQ_buf        <= 16'h80;
                 if (cnt_done)
                   begin
                     cntrl_state_o <= `chip_erase_3;
                   end
                 else
                   begin
                     cntrl_state_o   <= `chip_erase_2;
                   end
               end
           `chip_erase_3 :
               begin
                 inner_address <=  BYTE? 'h555 : 'hAAA;
                 DQ_buf        <= 16'hAA;
                 if (cnt_done)
                   begin
                     cntrl_state_o <= `chip_erase_4;
                   end
                 else
                   begin
                     cntrl_state_o   <= `chip_erase_3;
                   end
               end
           `chip_erase_4 :
               begin
                 inner_address <=  BYTE? 'h2AA : 'h555;
                 DQ_buf        <= 16'h55;
                 if (cnt_done)
                   begin
                     cntrl_state_o <= `chip_erase_5;
                   end
                 else
                   begin
                     cntrl_state_o   <= `chip_erase_4;
                   end
               end
           `chip_erase_5 :
               begin
                 inner_address <=  BYTE? 'h555 : 'hAAA;
                 DQ_buf        <= 16'h10;
                 if (cnt_done)
                   begin
                     cntrl_state_o <= `idle_1;
                   end
                 else
                   begin
                     cntrl_state_o   <= `chip_erase_5;
                   end
               end
          //    Six  cycle command needs to be used to erase the block of the Flash    // 
           `block_erase_0 :
               begin
                 inner_address <=  BYTE? 'h555 : 'hAAA;
                 DQ_buf        <= 16'hAA;
                 cmd_cycle     <=  3'b001;
                 if (cnt_done)
                   begin
                     cntrl_state_o <= `block_erase_1;
                   end
                 else
                   begin
                     cntrl_state_o   <= `block_erase_0;
                   end
               end
           `block_erase_1 :
               begin
                 inner_address <=  BYTE? 'h2AA : 'h555;
                 DQ_buf        <= 16'h55;
                 cmd_cycle     <=  3'b010;
                 if (cnt_done)
                   begin
                     cntrl_state_o <= `block_erase_2;
                   end
                 else
                   begin
                     cntrl_state_o   <= `block_erase_1;
                   end
               end
           `block_erase_2 :
               begin
                 inner_address <=  BYTE? 'h555 : 'hAAA;
                 DQ_buf        <= 16'h80;
                 cmd_cycle     <=  3'b011;
                 if (cnt_done)
                   begin
                     cntrl_state_o <= `block_erase_3;
                   end
                 else
                   begin
                     cntrl_state_o   <= `block_erase_2;
                   end
               end
           `block_erase_3 :
               begin
                 inner_address <= BYTE? 'h555 : 'hAAA;
                 DQ_buf        <= 16'hAA;
                 cmd_cycle     <=  3'b100;
                 if (cnt_done)
                   begin
                     cntrl_state_o <= `block_erase_4;
                   end
                 else
                   begin
                     cntrl_state_o   <= `block_erase_3;
                   end
               end
           `block_erase_4 :
               begin
                 inner_address <= BYTE? 'h2AA : 'h555;
                 DQ_buf        <= 16'h55;
                 cmd_cycle     <=  3'b101;
                 if (cnt_done)
                   begin
                     cntrl_state_o <= `block_erase_5;
                   end
                 else
                   begin
                     cntrl_state_o   <= `block_erase_4;
                   end
               end
           `block_erase_5 :
               begin
                 inner_address <= { avl_mm_mem_block_addr };        //Address of block to be erased is asserted.
                 DQ_buf        <= 16'h30;
                 cmd_cycle     <=  3'b110;
                 if (cnt_done)
                   begin
                     cntrl_state_o <= `idle_1;
                   end
                 else
                   begin
                     cntrl_state_o   <= `block_erase_5;
                   end
               end
            `erase_suspend :
              begin
                inner_address  <= 0;
                DQ_buf         <= 'hB0;
                if (cnt_done)
                  begin
                    cntrl_state_o <= `idle_1;
                    cmd_cycle     <=  3'b110;
                  end
                else
                  begin
                    cntrl_state_o  <= `erase_suspend;
                  end
              end 
           `erase_resume :
             begin
               inner_address  <= 0;
               DQ_buf         <= 'h30;
               if (cnt_done)
                 begin
                   cntrl_state_o <= `idle_1;
                 end
               else
                 begin
                   cntrl_state_o  <= `erase_resume;
                 end
             end
           `Read_1  :
             begin
               inner_address <= { avl_mm_mem_block_addr , avl_mm_mem_other_addr };
               cmd_cycle     <=  3'b010;
               if (cnt_done)
                 begin
                   cntrl_state_o <= `idle_1;
                 end
               else
                 begin
                   cntrl_state_o <= `Read_1;
                 end
             end
           `idle_1 :
             begin
               cmd_cycle <= 3'b000;
               cntrl_state_o <= `idle;
             end
          
          
         endcase
     end
endmodule
      