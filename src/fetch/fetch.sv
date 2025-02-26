//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Fetch                                                   
// Description: Holds all fetch stage modules.
//              Program Counter: 
//                  Points to the next instruction to be executed.
//                  Uses synchronous reset.        
//              Instruction Memory:
//                  Holds the program for the processor to execute 
//                  and outputs the instruction pointed to by the PC.  
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module fetch (
    input wire CLK, RST, PC_En,
    output wire [31:0] Instr_F, PC_F, PC_Plus_4_F
    );

    program_counter pc (
        .CLK(CLK),
        .RST(RST),
        .PC_En(PC_En),
        .PC_In(PC_Plus_4F),
        .PC_Out(PC_F)
    );

    adder32 pc_adder (
        .A(PC_F),
        .B(32'h4),
        .OUT(PC_Plus_4F)
    );

    instruction_memory imem (
        .PC_Out(PC),
        .Instr(Instr_F)
    );

endmodule

module program_counter (
    input wire CLK, RST, PC_En,
    input wire [31:0] PC_In,
    output logic [31:0] PC_Out
    );

    always_ff @ (posedge CLK) begin // Synchronous reset
        if (RST)
            PC_Out <= 32'b0;
        else if (PC_En)             
            PC_Out <= PC_In;           
    end
endmodule

module instruction_memory (
    input wire [31:0] PC_Out,
    output wire [31:0] Instr
    );

    logic [31:0] memory [0:255];

    initial begin
        $readmemh("src/program.hex", memory);
    end

    assign Instr = memory[PC_Out[31:2]]; // Use word aligned addressing
endmodule