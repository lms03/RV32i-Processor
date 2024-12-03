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
//              Fetch to Decode Pipeline Register:
//                  Holds the instruction and program counter to be passed to the decode stage.
//                  Uses synchronous reset and flush.    
// Author: Luke Shepherd                                                     
// Date Created: November 2024                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////


module fetch (
    input wire CLK, RST, PC_En,
    output wire [31:0] Instr_D, PC_D, PC_Plus_4_D
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
        .Instr(Instr_F)
    );

    ifid_reg ifid_reg (
        .CLK(CLK),
        .RST(RST),
        .Flush_D(0), //TEMPORARY, CHANGE LATER
        .Stall_En(0), //TEMPORARY, CHANGE LATER
        .Instr_F(Instr_F),
        .PC_F(PC),
        .PC_Plus_4_F(PC_Plus_4),
        .Instr_D(Instr_D),
        .PC_D(PC_D),
        .PC_Plus_4_D(PC_Plus_4_D)
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

module instruction_memory (
    input wire [31:0] PC_Out,
    output wire [31:0] Instr
    );

    reg [31:0] memory [0:255];

    initial begin
        $readmemh("src/program.hex", memory);
    end

    assign Instr = memory[PC_Out[31:2]]; // Use word aligned addressing
endmodule

module ifid_register (
    input wire CLK, RST, Flush_D, Stall_En,
    input wire [31:0] Instr_F, PC_F, PC_Plus_4_F,
    output reg [31:0] Instr_D, PC_D, PC_Plus_4_D
    );

    always @ (posedge CLK) begin // Synchronous flush and reset
        if (RST) begin
            Instr_D <= 32'h0;
            PC_D <= 32'h0;
            PC_Plus_4_D <= 32'h0;
        end
        else if (Flush_D) begin // Insert NOP (ADDI x0, x0, 0)
            Instr_D <= 32'h00000013;
            PC_D <= 32'h0;
            PC_Plus_4_D <= 32'h0;
        end
        else if (!Stall_En) begin
            Instr_D <= Instr_F;
            PC_D <= PC_F;
            PC_Plus_4_D <= PC_Plus_4_F;
        end
    end
endmodule