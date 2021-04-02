
`include "Defines.v"

//          AVALON Slave Interface            //

module avalon_slave (clk_i,
                     rst_i,
                     avl_mm_slave_addr_i,
                     avl_mm_slave_data_i,
                     avl_mm_slave_write,
                     avl_mm_slave_read,
                     ack,
                     avl_mm_slave_byteenable_i,
                     avl_mm_slave_waitrequest_o,
                     avl_mm_slave_data_o,
                     avl_mm_slave_IRQ_o,
                     avl_mm_slave_data_o,
                     avl_mm_slave_readdata_i,
                     avl_mm_mem_RY_BYn_i,
                     avl_mm_mem_DQdata_o,
                     avl_mm_mem_block_addr_o,
                     avl_mm_mem_other_addr_o,
                     avl_mm_mem_code_o,
                     avl_mm_mem_x8_lsb_address,
                     start);
  
//  Input Ports  //
   input clk_i;
   input rst_i;
   input ack;
   input [3:0] avl_mm_slave_addr_i;
   input [15:0] avl_mm_slave_data_i;
   input avl_mm_slave_write;
   input avl_mm_slave_read;
   input avl_mm_slave_byteenable_i;
   input [15:0] avl_mm_slave_readdata_i;           // Flash memory is ready for read or write or not
   input avl_mm_mem_RY_BYn_i;
 
// Output Ports   //
   output reg [15:0] avl_mm_mem_DQdata_o;         //Control FSM Access
   output reg [15:0] avl_mm_mem_other_addr_o;
   output reg [6:0] avl_mm_mem_block_addr_o;
   output reg [3:0] avl_mm_mem_code_o;
   output reg [15:0] avl_mm_slave_data_o;         //Master Access
   output reg [1:0] avl_mm_slave_IRQ_o;           
   output reg avl_mm_slave_waitrequest_o;          // Avalon Slave is ready for read or write or not
   output reg avl_mm_mem_x8_lsb_address;            // Flash Device LSB address in x8 mode
   output reg start; 
  
// Registers definition //
   reg block_addr_cs;                            // Select different Registers //
   reg other_addr_cs;
   reg tx_data_cs;
   reg rx_data_cs;
   reg ry_byn_cs;
   reg avl_mm_slave_write_reg;
   reg avl_mm_slave_read_reg; 
   reg cmd_code_cs;
   reg IRQ_cs;
   reg [15:0] latch_data;
   reg [4:0] counter_block_addr_cs;
   reg [4:0] counter_other_addr_cs;
   reg [4:0] counter_tx_data_cs;
   reg [4:0] counter_rx_addr_cs;
   reg [4:0] counter_cmd_code_cs;
   reg [4:0] counter_IRQ_cs;
   reg [2:0] counter_ack;
  

  // wait - request O/p  -- Pull up the high z to 1 //
  pullup(avl_mm_mem_RY_BYn_i);
  assign avl_mm_slave_waitrequest_o = ( avl_mm_mem_RY_BYn_i == 1'b0) ? 1'b1 : 1'b0 ; 


  //         Register mapping to the address offsets          //
   always @(posedge clk_i or posedge rst_i)
     begin
       if (rst_i == 1'b0)
         begin
           block_addr_cs <= 1'b0;
           other_addr_cs <= 1'b0;
           tx_data_cs    <= 1'b0;
           rx_data_cs    <= 1'b0;
           ry_byn_cs     <= 1'b0;
           cmd_code_cs   <= 1'b0;
           IRQ_cs        <= 1'b0;
         end
       else
         begin
           block_addr_cs <= avl_mm_slave_addr_i == 4'h1;
           other_addr_cs <= avl_mm_slave_addr_i == 4'h2;
           tx_data_cs    <= avl_mm_slave_addr_i == 4'h3;
           rx_data_cs    <= avl_mm_slave_addr_i == 4'h4;
           ry_byn_cs     <= avl_mm_slave_addr_i == 4'h5;
           cmd_code_cs   <= avl_mm_slave_addr_i == 4'h6;
           IRQ_cs        <= avl_mm_slave_addr_i == 4'h7;
         end
     end
  
  //          Write and Read pin is latched from Master                    //
   always @(posedge clk_i or posedge rst_i)
     begin
       if (rst_i == 1'b0)
         begin
           avl_mm_slave_write_reg <= 0;
           avl_mm_slave_read_reg  <= 0;
         end
       else
         begin
           avl_mm_slave_write_reg <= avl_mm_slave_write;
           avl_mm_slave_read_reg <= avl_mm_slave_read;
         end
     end
  
  //          Write latch data from slave                    //
   always @(posedge clk_i or posedge rst_i)
     begin
       if (rst_i == 1'b0)
         latch_data <= 0;
       else
         latch_data <= avl_mm_slave_data_i;
     end
  
  //        Write block address register                      //
   always @(posedge clk_i or posedge rst_i)
     begin
       if (rst_i == 1'b0)
         begin
           avl_mm_mem_block_addr_o <= 0;
           counter_block_addr_cs    <= 0;
         end
       else if (avl_mm_slave_write_reg && block_addr_cs)
         begin
           if(avl_mm_slave_byteenable_i <= 1'b1)
             begin
               avl_mm_mem_block_addr_o    <= latch_data[7:1];
               counter_block_addr_cs      <= counter_block_addr_cs + 1;
             end
           else
             begin
               avl_mm_mem_x8_lsb_address <= latch_data[0];
               avl_mm_mem_block_addr_o    <= latch_data[7:1];
               counter_block_addr_cs      <= counter_block_addr_cs + 1;
             end
         end
       else if (!block_addr_cs)
        begin
          counter_block_addr_cs    <= 0;
        end
     end
    
  //      Write other address register                       //
   always @(posedge clk_i or posedge rst_i)
     begin
       if (rst_i == 1'b0)
         begin
           avl_mm_mem_other_addr_o <= 0;
           counter_other_addr_cs    <= 0;
         end
       else if (avl_mm_slave_write_reg && other_addr_cs)
         begin
           avl_mm_mem_other_addr_o <= latch_data[15:0];
           counter_other_addr_cs   <= counter_other_addr_cs + 1;
         end
       else if (!other_addr_cs)
         begin
           counter_other_addr_cs    <= 0;
         end
     end
  
  //           Write tx_data register                      //
   always @(posedge clk_i or posedge rst_i)
     begin
       if (rst_i == 1'b0)
         begin
           avl_mm_mem_DQdata_o <= 0;
           counter_tx_data_cs <= 0;
         end
       else if (avl_mm_slave_write_reg && tx_data_cs)
         begin
           avl_mm_mem_DQdata_o <= avl_mm_slave_byteenable_i?latch_data:{8'b0,latch_data[7:0]};
          counter_tx_data_cs <= counter_tx_data_cs + 1;
         end
       else if (!tx_data_cs)
         begin
           counter_tx_data_cs    <= 0;
         end
     end
  
  //          Write Command code register                 //
   always @(posedge clk_i or posedge rst_i)
     begin
       if(rst_i == 1'b0)
         begin
           avl_mm_mem_code_o <= 0;
           counter_cmd_code_cs <= 0;
         end
       else if(avl_mm_slave_write_reg && cmd_code_cs)
         begin
           avl_mm_mem_code_o   <= latch_data [3:0];
           counter_cmd_code_cs <= counter_cmd_code_cs + 1;
         end
       else if (!cmd_code_cs)
         begin
           counter_cmd_code_cs    <= 0;
         end
     end
  
  //             Read Rx_data register                    //
   always @(posedge clk_i or posedge rst_i)
     begin
       if (rst_i == 1'b0)
         begin
           avl_mm_slave_data_o <= 0;
           counter_rx_addr_cs <= 0;
         end
       else if (avl_mm_slave_read_reg && rx_data_cs )
         begin
           avl_mm_slave_data_o <=  block_addr_cs ? avl_mm_mem_block_addr_o     :
                                   other_addr_cs ? avl_mm_mem_other_addr_o     :
                                   tx_data_cs    ? avl_mm_mem_DQdata_o         :
                                   rx_data_cs    ? avl_mm_slave_readdata_i     :
                                   ry_byn_cs     ? avl_mm_mem_RY_BYn_i         :
                                   cmd_code_cs   ? avl_mm_mem_code_o           :
                                   IRQ_cs        ? avl_mm_slave_IRQ_o          :
                                   16'h0;
           counter_rx_addr_cs <= counter_rx_addr_cs + 1;
         end
       else if (!rx_data_cs)
         begin
           counter_rx_addr_cs    <= 0;
         end
     end
  
   always @(posedge clk_i or posedge rst_i)
     begin
       if (rst_i == 1'b0)
         avl_mm_slave_IRQ_o <= 2'b00;
       else
         begin
           if ( avl_mm_mem_code_o == 4'h7 && other_addr_cs )
             avl_mm_slave_IRQ_o <= 2'b01;
           else if ( avl_mm_mem_code_o > 4'h7 )
             avl_mm_slave_IRQ_o <= 2'b10;
           else if ( avl_mm_slave_addr_i > 4'h7 )
             avl_mm_slave_IRQ_o <= 2'b11;
           else
             avl_mm_slave_IRQ_o <= 2'b00;
         end
     end
  
  /*// When memory is busy or any register selected twice waitrequest is asserted //
   always @(posedge clk_i or posedge rst_i)
     begin
       if (rst_i == 1'b0)
         avl_mm_slave_waitrequest_o <= 1'b0;
       else
         begin
           if ( counter_block_addr_cs > 1 || !avl_mm_mem_RY_BYn_o)
             avl_mm_slave_waitrequest_o <= 1'b1;
           else if ( counter_other_addr_cs > 1 || !avl_mm_mem_RY_BYn_o)
             avl_mm_slave_waitrequest_o <= 1'b1;
           else if ( counter_tx_data_cs > 1    || !avl_mm_mem_RY_BYn_o)
             avl_mm_slave_waitrequest_o <= 1'b1;
           else if ( counter_rx_addr_cs > 1    || !avl_mm_mem_RY_BYn_o)
             avl_mm_slave_waitrequest_o <= 1'b1;
           else if ( counter_cmd_code_cs > 1   || !avl_mm_mem_RY_BYn_o)
             avl_mm_slave_waitrequest_o <= 1'b1;
          // Wait states for four clock cycles and till the memory is busy //
           else if ( counter_cmd_code_cs > 3   || counter_block_addr_cs > 3 || counter_other_addr_cs > 3 || counter_tx_data_cs > 3|| counter_rx_addr_cs > 3 || avl_mm_mem_RY_BYn_o)
             avl_mm_slave_waitrequest_o <= 1'b0;
         end
     end*/

   always @(posedge clk_i or posedge rst_i)  //-----------GENERATING START BIT FOR FLASH DEVICE OPERATIONS---------------
     begin
       if (rst_i == 1'b0)
         begin
           counter_ack <= 3'b0;
           start <= 1'b0;
         end
       else
         begin
           if(cmd_code_cs == 1'b1)
             begin
               if((avl_mm_mem_code_o == 4'b0001) | (avl_mm_mem_code_o == 4'b0010) | (avl_mm_mem_code_o == 4'b0110)|(avl_mm_mem_code_o == 4'b0111))  //(avl_mm_mem_code_o == 4'b0010)
                 begin
                   if(ack == 1'b0)
                     begin
                       if(counter_ack == 3'b001)
                         start <= 1'b0;
                       else if(counter_ack > 3'b001)          
                         counter_ack <= 3'b0;
                       else
                         start <= 1'b1;
                     end
                   else
                     counter_ack <= counter_ack + 3'b001 ;
                 end
               else if((avl_mm_mem_code_o == 4'b0100)| (avl_mm_mem_code_o == 4'b0101))
                 begin
                   if(ack == 1'b0)
                     begin
                       if(counter_ack == 3'b110)
                         start <= 1'b0;
                       else if(counter_ack > 3'b110)
                         counter_ack <= 3'b0;
                       else
                         start <= 1'b1;
                     end
                   else
                     counter_ack <= counter_ack + 3'b001 ;
                 end 
               else if(avl_mm_mem_code_o == 4'b0011)
                 begin
                   if(ack == 1'b0)
                     begin
                       if(counter_ack == 3'b100)
                         start <= 1'b0;
                       else if(counter_ack > 3'b100)
                         counter_ack <= 3'b0;
                       else
                         start <= 1'b1;
                     end
                   else
                     counter_ack <= counter_ack + 3'b001 ;
                 end          
               else
                 begin
                   start <= 1'b0;
                   counter_ack <= 3'b0;
                 end 
             end
           else
             start <= 1'b0;
         end

     end



endmodule

