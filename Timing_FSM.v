// Code your design here
`include "Defines.v"

//         Timing FSM          //
module timing_fsm(

   input   clk_i,
   input   rst_i,
   input   [`ADDRESS_WIDTH-1:0] address,
   input   byteenable,
   input   [`CONTROL_FSM_STATE_WIDTH-1:0] cntrl_op,
   input   [`COMMAND_OP_CYCLES-1:0] cmd_op_cycles,
   input   [`DATA_WORD_WIDTH-1:0] wrdata,
   //input   RY_BYn,
   //input    [`DATA_WORD_WIDTH-1:0]  read_data_i,
   output  reg ack,
   //output  reg [`DATA_WORD_WIDTH-1:0] data_read,
   output  reg OEn,
   output  reg CEn,
   output  reg WEn,
   output  reg BYTEn,
   output  reg RSTn,
   output  reg [`ADDRESS_WIDTH-1:0] ADDR,
   output   [`DATA_WORD_WIDTH-1:0] write_data_o,
   output  reg data_i_enable,
   output  reg data_o_enable,
   output  reg signal_drive,
   output  reg signal_drives,
   output  reg signals_drive);

   assign write_data_o = wrdata ;
   //assign data_read = read_data_i;
  
/* REGISTERS FOR GENERATING FLASH MEMORY DEVICE SIGNALS */ 
   reg [7:0] timing_counter;
   reg [7:0] counter;
   reg [3:0] timing_cntrl_state;
 


   always @ (posedge clk_i or negedge rst_i)
     if(rst_i == 1'b0)
       begin
         data_i_enable <= 1'b0;
         data_o_enable <= 1'b0;            
         timing_counter <= 8'b0;
         ack <= 1'b0;
         signal_drive <= 1'b0;
         signals_drive <= 1'b0;
         signal_drives <= 1'b0;
         //timing_cntrl_state <= `RESET;
       end
     else
       begin
         RSTn <= 1'b1;
         BYTEn <= 1'b1;
         case(timing_cntrl_state)

        // Timing Protocol for The reset of the device //
           `RESET:
             begin
               if(timing_counter <= 8'b00000010)
                 begin
                   CEn <= 1'b1;
                   OEn <= 1'b1;
                   RSTn <= 1'b1;
                   timing_counter <= timing_counter + 8'b00000001;
                 end
               else if(timing_counter == 8'b00000011)//3ns
                 begin
                   RSTn <= 1'b0;
                   timing_counter <= timing_counter + 8'b00000001;
                 end
               else if(timing_counter == 8'b00001110)//14ns
                 begin
                   RSTn <= 1'b1;
                   timing_counter <= timing_counter + 1;
                 end
               else if(timing_counter == 8'b00010100)//20ns
                 begin
                   ack <= 1'b1;
                   timing_counter <= timing_counter + 1;
                 end
               else if(timing_counter == 8'b00010101)//21ns
                 begin
                   ack <= 1'b0;
                   timing_counter <= 8'b0;
                 end
               else
                 begin
                   CEn <= 1'b1;
                   OEn <= 1'b1;
                   timing_counter <= timing_counter + 1;
                 end
             end

        // Timing Protocol for the read from FLASH //
           `READ:
             begin
               if(byteenable == 1'b0)
                 begin
                   if(cmd_op_cycles == 3'b010)
                     begin
                       if(timing_counter <= 8'b00000010)             //2ns
                         begin
                           CEn<= 1'b1;
                           BYTEn <= 1'b0;
                           ack <= 1'b0;
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                       else if(timing_counter == 8'b00000011)           //3//OE 25ns.
                         begin
                           ADDR <= address;
                           CEn <= 1'b0;
                           BYTEn <= 1'b1;
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                       else if(timing_counter == 8'b00001000)  //8ns
                         begin
                           BYTEn <= 1'b0;
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                       else if(timing_counter == 8'b00001010)      //10ns
                         begin
                           data_i_enable <= 1'b1;
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                       else if(timing_counter == 8'b00001100)    //12ns
                         begin
                           CEn <= 1'b1;
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                       else if(timing_counter == 8'b00001101)    //13ns
                         begin
                           ADDR <= 23'b0;
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                       else if(timing_counter == 8'b00001110)   //14ns
                         begin
                           data_i_enable <= 1'b0;
                           ack <= 1'b1;
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                       else if(timing_counter == 8'b00001111)   //15ns
                         begin
                           ack <= 1'b0;
                           timing_counter <= 8'b0;
                         end
                       else
                         begin
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                     end
                   else
                     begin
                       timing_counter <= 8'b0;
                       CEn <= 1'b1;
                       OEn <= 1'b1;
                       WEn <= 1'b1;
                     end
                 end
               else
                 begin
                   if(cmd_op_cycles == 3'b010)
                     begin
                       if(timing_counter <= 8'b00000010)             //2ns
                         begin
                           CEn <= 1'b1;
                           BYTEn <= 1'b1;
                           ack <= 1'b0;
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                       else if(timing_counter == 8'b00000011)           //3//OE 25ns.
                         begin
                           ADDR <= address;
                           CEn <= 1'b0;
                           BYTEn <= 1'b0;
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                       else if(timing_counter == 8'b00000100)  //4ns
                         begin
                           BYTEn <= 1'b1;
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                       else if(timing_counter == 8'b00001010)      //10ns
                         begin
                           data_i_enable <= 1'b1;
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                       else if(timing_counter == 8'b00001100)    //12ns
                         begin
                           CEn <= 1'b1;
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                       else if(timing_counter == 8'b00001101)    //13ns
                         begin
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                       else if(timing_counter == 8'b00001110)   //14ns
                         begin
                           data_i_enable <= 1'b0;
                           ack <= 1'b1;
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                       else if(timing_counter == 8'b00001111)   //15ns
                         begin
                           ack <= 1'b0;
                           timing_counter <= 8'b0;
                         end
                       else
                         begin
                           timing_counter <= timing_counter + 8'b00000001;
                         end
                     end
                   else
                     begin
                       timing_counter <= 8'b0;
                       CEn <= 1'b1;
                       OEn <= 1'b1;
                       WEn <= 1'b1;
                     end
                 end
             end
         
          // Timing Protocol for programming the FLASH //
           `PROGRAM:
             begin
               if(cmd_op_cycles == 3'b001)
                 begin
                   if(timing_counter == 8'b00000010)//2 cc
                     begin
                       data_o_enable <= 1'b0;
                       signal_drive <= 1'b1;
                       OEn <= 1'b1;
                       CEn <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00000111)//7 cc
                     begin
                       signal_drives <= 1'b1;
                       WEn <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end                           
                   else if(timing_counter == 8'b00001100)//12 cc       
                     begin
                       signals_drive <= 1'b1;
                       ADDR <= address;
                       timing_counter <= timing_counter + 8'b00000001;
                     end                     
                   else if(timing_counter == 8'b00001101)//13 cc        
                     begin
                       CEn <= 1'b0;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00001110)// 14cc       
                     begin
                       WEn <= 1'b0;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00001111)// 15 cc        
                     begin 
                       data_o_enable <= 1'b1;        
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00010100)// 20cc       
                     begin
                       WEn <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if ( timing_counter == 8'b00010101)// 21cc
                     begin
                       CEn <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if ( timing_counter == 8'b00010110)// 22 cc     
                     begin
                       data_o_enable <= 1'b0;
                       ack <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if ( timing_counter == 8'b00010111)// 23 cc     
                     begin
                        ack <= 1'b0;
                        timing_counter <= 8'b0;
                     end
                   else
                     begin
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                 end
               else if((cmd_op_cycles == 3'b010) || (cmd_op_cycles == 3'b011))
                 begin
                  if(timing_counter == 8'b00000101)//5 cc       
                     begin
                       ADDR <= address;
                       timing_counter <= timing_counter + 8'b00000001;
                     end                     
                   else if(timing_counter == 8'b00000110)//6 cc        
                     begin
                       CEn <= 1'b0;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00000111)// 7cc       
                     begin
                       WEn <= 1'b0;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00001000)// 8 cc        
                     begin 
                       data_o_enable <= 1'b1;        
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00001101)// 13cc       
                     begin
                       WEn <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if ( timing_counter == 8'b00001110)// 14cc
                     begin
                       CEn <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if ( timing_counter == 8'b00001111)// 15 cc     
                     begin
                       data_o_enable <= 1'b0;
                       ack <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if ( timing_counter == 8'b00010000)// 16 cc     
                     begin
                        ack <= 1'b0;
                        timing_counter <= 8'b0;
                     end
                   else
                     begin
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                 end
               else if(cmd_op_cycles == 3'b100)
                 begin
                   if(timing_counter == 8'b00000101)//5 cc       
                     begin
                       ADDR <= address;
                       timing_counter <= timing_counter + 8'b00000001;
                     end                     
                   else if(timing_counter == 8'b00000110)//6 cc        
                     begin
                       CEn <= 1'b0;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00000111)// 7cc       
                     begin
                       WEn <= 1'b0;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00001000)// 8 cc        
                     begin 
                       data_o_enable <= 1'b1;        
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00001101)// 13cc       
                     begin
                       WEn <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if ( timing_counter == 8'b00001110)// 14cc
                     begin
                       CEn <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if ( timing_counter == 8'b00001111)// 15 cc     
                     begin
                       data_o_enable <= 1'b0;
                       ack <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if ( timing_counter == 8'b00010000)// 16 cc     
                     begin
                        ack <= 1'b0;
                        timing_counter <= 8'b0;
                     end
                   else
                     begin
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                 end
               else
                 begin
                    timing_counter <= 8'b0;
                 end
             end

        // Timing Protocol for the ERASE of the FLASH //
           `CHIP_ERASE:
             begin
               if(cmd_op_cycles <= 110)
                 begin
                   if(timing_counter == 8'b00000011)//3ns
                     begin
                       ADDR <= address;
                       CEn <= 1'b0;
                       OEn <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00000110)//6ns
                     begin
                       WEn <= 1'b0;
                       data_o_enable <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00001010)//10ns
                     begin
                       data_o_enable <= 1'b0;
                       WEn <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00001011)//11ns
                     begin
                       CEn <= 1'b1;
                       ack <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00001100)//12ns
                     begin
                       ack <= 1'b0;
                       timing_counter <= 8'b0;
                     end
                   else
                     begin
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                 end
               else
                 begin
                   CEn <= 1'b1;
                   OEn <= 1'b1;
                   WEn <= 1'b1;
                 end
             end

         // Timing Protocol for the BLOCK ERASE of the FLASH //
           `BLOCK_ERASE:
             begin
               if(cmd_op_cycles <= 110)
                 begin
                   if(timing_counter == 8'b00000011)//3ns
                     begin
                       ADDR <= address;
                       CEn <= 1'b0;
                       OEn <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00000110)//6ns
                     begin
                       WEn <= 1'b0;
                       data_o_enable <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00001010)//10ns
                     begin
                       data_o_enable <= 1'b0;
                       WEn <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00001011)//11ns
                     begin
                       CEn <= 1'b1;
                       ack <= 1'b1;
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                   else if(timing_counter == 8'b00001100)//12ns
                     begin
                       ack <= 1'b0;
                       timing_counter <= 8'b0;
                     end
                   else
                     begin
                       timing_counter <= timing_counter + 8'b00000001;
                     end
                 end
             end
 
         // Timing Protocol for the ERASE_suspend operation //
           `ERASE_SUSPEND:
             begin
               if(timing_counter == 8'b00000011)//3ns
                 begin
                   ADDR <= address;
                   CEn <= 1'b0;
                   OEn <= 1'b1;
                   timing_counter <= timing_counter + 8'b00000001;
                 end
               else if(timing_counter == 8'b00000110)//6ns
                 begin
                   WEn <= 1'b0;
                   data_o_enable <= 1'b1;
                   timing_counter <= timing_counter + 8'b00000001;
                 end
               else if(timing_counter == 8'b00001010)//10ns
                 begin
                   data_o_enable <= 1'b0;
                   WEn <= 1'b1;
                   timing_counter <= timing_counter + 8'b00000001;
                 end
               else if(timing_counter == 8'b00001011)//11ns
                 begin
                   CEn <= 1'b1;
                   ack <= 1'b1;
                   timing_counter <= timing_counter + 8'b00000001;
                 end
               else if(timing_counter == 8'b00001100)//12ns
                 begin
                   ack <= 1'b0;
                   timing_counter <= 8'b0;
                 end
               else
                 begin
                   timing_counter <= timing_counter + 8'b00000001;
                 end
             end

          // Timing Protocol for the ERASE_resume operation //
           `ERASE_RESUME:
             begin
               if(timing_counter == 8'b00000011)//3ns
                 begin
                   ADDR <= address;
                   CEn <= 1'b0;
                   OEn <= 1'b1;
                   timing_counter <= timing_counter + 8'b00000001;
                 end
               else if(timing_counter == 8'b00000110)//6ns
                 begin
                   WEn <= 1'b0;
                   data_o_enable <= 1'b1;
                   timing_counter <= timing_counter + 8'b00000001;
                 end
               else if(timing_counter == 8'b00001010)//10ns
                 begin
                   data_o_enable <= 1'b0;
                   WEn <= 1'b1;
                   timing_counter <= timing_counter + 8'b00000001;
                 end
               else if(timing_counter == 8'b00001011)//11ns
                 begin
                   CEn <= 1'b1;
                   ADDR <= address;
                   ack <= 1'b1;
                   timing_counter <= timing_counter + 8'b00000001;
                 end
               else if(timing_counter == 8'b00001100)//12ns
                 begin
                   ack <= 1'b0;
                   timing_counter <= 8'b0;
                 end
               else
                 begin
                   timing_counter <= timing_counter + 8'b00000001;
                 end
             end
         endcase
       end
  
  
   always @ (posedge clk_i or negedge rst_i)
     if(rst_i == 1'b0)
       begin
         timing_cntrl_state <= 4'b0; 
       end
     else
       begin
         timing_cntrl_state <= cntrl_op;
       end
        
  
  
  // Timing Protocol for the read operation to follow the data_valid timings //
   always @ (negedge clk_i or negedge rst_i)
     if(rst_i == 1'b0)
       begin
         OEn <= 1'bZ;
         counter <= 8'b0;
       end
     else
       begin
         if(cntrl_op == `READ && cmd_op_cycles == 3'b010)
           begin
             if(BYTEn == 1'b0)
               begin
                 if(ack == 1'b0)
                   begin
                     if(counter == 8'b00001000)//8ns
                       begin
                         OEn <= 1'b0;
                         counter <= counter + 8'b00000001 ;
                       end
                     else if(counter == 8'b00001100)//12ns
                       begin
                         OEn <= 1'b1;
                         counter <= counter + 8'b00000001 ;
                       end
                     else
                       begin
                         counter <= counter + 8'b00000001 ;
                       end
                   end
                 else 
                   begin
                     counter <= 8'b0;
                   end
               end
             else
               begin
                 if(ack == 1'b0)
                   begin
                     if(counter == 8'b00001000)//8ns
                       begin
                         OEn <= 1'b0;
                         counter <= counter + 8'b00000001 ;
                       end
                     else if(counter == 8'b00001100)//12ns
                       begin
                         OEn <= 1'b1;
                         counter <= counter + 8'b00000001 ;
                       end
                     else
                       begin
                         counter <= counter + 8'b00000001 ;
                       end
                   end
                 else 
                   begin
                     counter <= 8'b0;
                   end
               end
           end
         else
           begin
             counter <= 8'b0;
           end
       end
  

  
  
endmodule
