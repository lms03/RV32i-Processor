//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Core                                           
// Description: Instantiates all modules and connects them together               
// Author: Luke Shepherd                                                     
// Date Created: November 2024                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

module core (
    input wire CLK,
    input wire RST
    );

    // PC Signals
    wire [31:0] PC_In;
    wire [31:0] PC_Out;
    wire [31:0] PC_Plus_4;
    wire PC_En;

    fetch fetch (
        .CLK(CLK),
        .RST(RST),
        .PC_En(PC_En),
        .Instr(Instr),
        .PC_Out(PC_Out),
        .PC_Plus_4(PC_Plus_4)
    );


endmodule