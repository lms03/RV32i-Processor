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
    wire PC_En;

    program_counter pc (
        .CLK(CLK),
        .RST(RST),
        .PC_En(PC_En),
        .PC_In(PC_In),
        .PC_Out(PC_Out)
    );

    // Adder to increment PC to PC+4
    adder pc_adder (
        .A(PC_Out),
        .B(32'h4),
        .OUT(PC_In)
    );
endmodule