//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Instruction Memory                                                      
// Description: Holds the program for the processor to execute 
//              and outputs the instruction pointed to by the PC                
// Author: Luke Shepherd                                                     
// Date Created: November 2024                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

module instruction_memory (
    input wire [31:0] PC_Out,
    output reg [31:0] Instr
    );

    reg [31:0] memory [0:255];

    initial begin
        $readmemh("src/program.hex", memory);
    end

    always @(*) begin
        Instr = memory[PC_Out[9:2]];
    end
endmodule