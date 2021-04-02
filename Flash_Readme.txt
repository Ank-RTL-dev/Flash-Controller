//-----------------     TATA  ELXSI  -----------------------//
//------------   FLASH CONTROLLER   ----------------//
//--------   Release Date : 30-March_2021   ----- //

>>>>>>>>>>>>>>>>>>  Author <<<<<<<<<<<<<<<<<<<<<<<
             1.) Saqlinahamad A Makandar
             2.) Ankur Kumar

>>>>>>>>>>>>>>>>>>>>>>>>   The Release Folder Consists of the following   <<<<<<<<<<<<<<<<<<<<<<<

1.) RTL design folder

    -> RTL Codes for different Modules along with model TB  | RTL Code Folder 
    -> Readme File for the RTL code folder            | FLASH_RTL_readme.txt
    -> System Requirement Specifications doc       | FLASH CONTROLLER_SRS.docx
    -> High Level Design doc                                  | Flash_Controller_HLD_v3.0.docx
    -> Requirement Specifications doc feedbacks sheet          | SRS_Review-10-feb2021.xlsx 
    -> High level Design doc Review and Feedbacks sheet     | HLD_Review-03March-05March2021.xlsx
    -> Design Reviews, Bugs Reported and their resolutions sheet  | RTL_feedbacks_bugs.xlsx
    -> Snips of the functionalities Supported by the Design  | Program.png | Read.png | Program_Read.png

2.) RTL Verification folder 

    -> Test Plan                   | Flash Controller Test Plan.xlsx
    -> Feature Extraction    | Feature_Extraction_Flash_Controller.xlsx
    -> Test Bench Code                                            |  flash_controller_tb.v
    -> Reviews and feedbacks on FE, TP and TB     |  Review on feature_extraction_flash_controller.xlsx
    -> include folder for memory model simulation  | include
    -> defines file                                 | define_tb.v
    -> Memory Model Code                 | mt28ew.v
    -> Snips of the Bugs Reported       | Bugs_snips.docx
    -> Transcripts for different opeartions | log files Folder

3.) Memory model datasheet  | Micron_NOR_Flash_128Mb.pdf
 
4.) Avalon Memory Mapped Protocol datasheet | mnl_avalon_spec.pdf

5.) Project Status and Planning | Mini-Project_Status.xlsx


>>>>>>>>>>>>>>>>>>>>>>   Supported Features and Dependancies   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

1.) The Controller supports the Program, Read and Program-Read simultaneously.

2.) All the timing protocol for the MT28EW128ABA memory model has been followed.

3.) The controller design is compatible with the Parallel Nor FLASH memory MT28EW128ABA.

4.) It supports only x16 mode opeartions on the memory.


>>>>>>>>>>>>>>>>>>>>>>>>>> >>>      Future Enhancements   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

1.) The Controller can be also configured to work in x8 bit mode by doing modifications in the Avalon Slave module and the Flash_Top module.

2.) It can be configured to support any MICRON Parallel Flash memory by changing the parameters value in the defines file and also making modifications in the Timing Fsm.

3.) It can also support Block Erase and Chip Erase opeartions on the Memory by making some modifications in the Contol and Timing Fsm.


