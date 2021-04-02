

>>>>>>>>>>>>>>>>>>  Author <<<<<<<<<<<<<<<<<<<<<<<
                   Ankur Kumar


>>>>>>>>>>>>>>>>>>>>>>   Supported Features and Dependancies   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

1.) The Controller supports the Program, Read and Program-Read simultaneously.

2.) All the timing protocol for the MT28EW128ABA memory model has been followed.

3.) The controller design is compatible with the Parallel Nor FLASH memory MT28EW128ABA.

4.) It supports only x16 mode opeartions on the memory.


>>>>>>>>>>>>>>>>>>>>>>>>>> >>>      Future Enhancements   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

1.) The Controller can be also configured to work in x8 bit mode by doing modifications in the Avalon Slave module and the Flash_Top module.

2.) It can be configured to support any MICRON Parallel Flash memory by changing the parameters value in the defines file and also making modifications in the Timing Fsm.

3.) It can also support Block Erase and Chip Erase opeartions on the Memory by making some modifications in the Contol and Timing Fsm.


