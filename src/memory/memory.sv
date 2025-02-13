//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Memory                                                   
// Description: Holds all Memory stage modules.
//              Data Memory: 
//                  Holds the data for the program to operate on and allows read/writes.
// Author: Luke Shepherd
// Date Modified: February 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module memory ();
endmodule

module data_memory (
    input wire CLK, MEM_W_En, 
    input wire [2:0] MEM_Control,
    input wire [31:0] ALU_Out, REG_R_Data2,
    output logic [31:0] Data_Out
    );

    logic [31:0] memory [0:255];

    always_ff @ (posedge CLK) begin
        if (MEM_W_En) begin
            case (MEM_Control)
                MEM_BYTE: memory[ALU_Out[7:0]][7:0] <= REG_R_Data2[7:0];
                MEM_HALFWORD: memory[ALU_Out[7:0]][15:0] <= REG_R_Data2[15:0];
                MEM_WORD: memory[ALU_Out[7:0]] <= REG_R_Data2;
                default: memory[ALU_Out[7:0]] <= memory[ALU_Out[7:0]];
            endcase
        end   
    end

    always_comb begin
        case (MEM_Control)
            MEM_BYTE: Data_Out = {{24{memory[ALU_Out[7:0]][7]}}, memory[ALU_Out[7:0]][7:0]};
            MEM_BYTE_UNSIGNED: Data_Out = {24'h0, memory[ALU_Out[7:0]][7:0]};
            MEM_HALFWORD: Data_Out = {{16{memory[ALU_Out[7:0]][15]}}, memory[ALU_Out[7:0]][15:0]};
            MEM_HALFWORD_UNSIGNED: Data_Out = {16'h0, memory[ALU_Out[7:0]][15:0]};
            MEM_WORD: Data_Out = memory[ALU_Out[7:0]];
            default: Data_Out = 32'h0;
        endcase
    end
endmodule