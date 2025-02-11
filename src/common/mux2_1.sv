//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: 2 to 1 Multiplexer                                                   
// Description: Generic 2 to 1 multiplexer used to select between two inputs.
// Author: Luke Shepherd                                                     
// Date Created: February 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

module mux2_1 (
    input wire SEL,
    input wire [31:0] IN0, IN1,
    output wire [31:0] OUT
    );

    assign OUT = SEL ? IN1 : IN0;
endmodule