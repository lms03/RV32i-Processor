//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: 32-bit Adder                                                  
// Description: Generic 32-bit adder used to increment the PC and for branch target calculations.  
// Author: Luke Shepherd                                                     
// Date Created: November 2024                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

module adder32 (
    input wire [31:0] A,
    input wire [31:0] B,
    output wire [31:0] OUT
    );

    assign OUT = A + B;
endmodule