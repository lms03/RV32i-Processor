//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: 3 to 1 Multiplexer                                                   
// Description: Generic 3 to 1 multiplexer used to select between two inputs.
// Author: Luke Shepherd                                                     
// Date Created: March 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

module mux3_1 (
    input wire SEL,
    input wire [31:0] A, B, C
    output wire [31:0] OUT
    );

    assign OUT = (SEL == 2'b00) ? A : (SEL == 2'b01) ? B : (SEL == 2'b10) ? C : 32'h0;
endmodule