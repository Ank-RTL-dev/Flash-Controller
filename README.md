# Flash-Controller

•	Design of FLASH CONTROLLER that supports 128Mb MICRON PARALLEL NOR FLASH MEMORY which has 23-bit address lines and 16-bit data lines

•	 The Flash Controller architecture consists of Four Major Blocks 
             a.) AVALON MM Slave Interface 
             b.) Command Decoder 
             c.) Control FSM
             d.) Timing FSM

•	Avalon MM Slave Interface - This design has a standard AVALON MM slave bus that connects the NOR Flash memory device with the IBEX core. From the AVALON MM bus, this design appears as a set of addressable registers that can be read from or written to. Through these registers, the AVALON MM master can transmit and receive data and control the operation of the NOR Flash memory. It takes the address, command and data from the AVALON MM master which is the IBEX core.

•	Command Decoder – It is used to decode the command coming from the master and then accordingly sending those to the CONTROL FSM. Command codes for different operations to happen are stored in the cmd_code register and decoded to do start the Control FSM.

•	Control FSM – The control Finite State Machine (FSM) is used to enter the appropriate operational modes of NOR Flash based on O/P coming from the command decoder. For every operational mode of FLASH, Control FSM calls a Timing FSM.

•	Timing FSM – The Timing FSM is used to generate the required control signals to access the NOR Flash based on the NOR Flash memory timing specification.

Supported Interface parameters
 -> System Interface: AVALON MM Interface
  
Supported Operations
 •	RESET
 •	READ
 •	PROGRAM
 •	CHIP ERASE
 •	BLOCK ERASE

•	Functional verification of the design is done in ModelSim using one testbench
