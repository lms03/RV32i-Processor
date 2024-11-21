//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Adder                                           
// Description: Generic 32bit adder for PC increment and branch address calculation.           
// Author: Luke Shepherd                                                     
// Date Created: November 2024                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

module adder (
    input wire [31:0] A,
    input wire [31:0] B,
    output reg [31:0] OUT
    );

    assign OUT = A + B;
endmodule