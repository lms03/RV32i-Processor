//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Fetch                                                   
// Description: Holds all fetch stage modules.
//              Program Counter: 
//                  Points to the next instruction to be executed.
//                  Uses synchronous reset.        
//              Adder:
//                  Increments the PC.
//              Instruction Memory:
//                  Holds the program for the processor to execute 
//                  and outputs the instruction pointed to by the PC.   
// Author: Luke Shepherd                                                     
// Date Created: November 2024                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////


module fetch (
    input wire CLK, RST, PC_En,
    output wire [31:0] Instr, PC, PC_Plus_4
    );

    program_counter pc (
        .CLK(CLK),
        .RST(RST),
        .PC_En(PC_En),
        .PC_In(PC_Plus_4),
        .PC_Out(PC)
    );

    adder pc_adder (
        .A(PC),
        .B(32'h4),
        .OUT(PC_Plus_4)
    );

    instruction_memory imem (
        .PC_Out(PC),
        .Instr(Instr)
    );

endmodule

module program_counter (
    input wire CLK, RST, PC_En,
    input wire [31:0] PC_In,
    output reg [31:0] PC_Out
    );

    always @ (posedge CLK) begin // Synchronous reset
        if (RST)
            PC_Out <= 32'h0;
        else if (PC_En)             
            PC_Out <= PC_In;           
    end
endmodule

module adder (
    input wire [31:0] A,
    input wire [31:0] B,
    output wire [31:0] OUT
    );

    assign OUT = A + B;
endmodule

module instruction_memory (
    input wire [31:0] PC_Out,
    output reg [31:0] Instr
    );

    reg [31:0] memory [0:255];

    initial begin
        $readmemh("src/program.hex", memory);
    end

    always @(*) begin
        Instr = memory[PC_Out[9:2]]; // Use word aligned addressing
    end
endmodule