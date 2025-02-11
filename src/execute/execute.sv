//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Execute                                                   
// Description: Holds all Execute stage modules.
//              ALU: 
//                  Performs arithmetic and logical operations on two operands.
// Date Modified: February 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module execute (
    // Control unit signals
    input wire REG_W_En_E, MEM_W_En_E, Jump_En_E, Branch_En_E,
    input wire [2:0] MEM_Control_E,
    input wire [3:0] ALU_Control_E,
    input wire Branch_Src_Sel_E,
    input wire ALU_SrcA_Sel_E, ALU_SrcB_Sel_E,
    input wire [1:0] Result_Src_Sel_E,

    // Register data
    input wire [4:0] RD_E, RS1_E, RS2_E,
    input wire [31:0] REG_R_Data1_E, REG_R_Data2_E,

    // Extended Immediate
    input wire [31:0] Imm_Ext_E,

    // PC
    input wire [31:0] PC_E, PC_Plus_4_E
    );


endmodule

module arithmetic_logic_unit (
    input wire [3:0] ALU_Control,
    input wire [31:0] SrcA, SrcB,
    output logic [31:0] Result,
    output logic Branch_Condition
    );
    
    // ALU operations
    always_comb begin
        case (ALU_Control)
            ALU_ADD: Result = SrcA + SrcB;
            ALU_SUB: Result = SrcA - SrcB;
            ALU_AND: Result = SrcA & SrcB;
            ALU_OR: Result = SrcA | SrcB;
            ALU_XOR: Result = SrcA ^ SrcB;
            ALU_SLL: Result = SrcA << SrcB;
            ALU_SRL: Result = SrcA >> SrcB;
            ALU_SRA: Result = SrcA >>> SrcB;
            ALU_BEQ: 
                begin
                    if (SrcA == SrcB) Branch_Condition = 1'b1;
                    else Branch_Condition = 1'b0;
                end
            ALU_BNE: 
                begin
                    if (SrcA != SrcB) Branch_Condition = 1'b1;
                    else Branch_Condition = 1'b0;
                end
            ALU_BLT: 
                begin
                    if ($signed(SrcA) < $signed(SrcB)) Branch_Condition = 1'b1;
                    else Branch_Condition = 1'b0;
                end
            ALU_BLTU: 
                begin
                    if (SrcA < SrcB) Branch_Condition = 1'b1;
                    else Branch_Condition = 1'b0;
                end
            ALU_BGE: 
                begin
                    if ($signed(SrcA) >= $signed(SrcB)) Branch_Condition = 1'b1;
                    else Branch_Condition = 1'b0;
                end
            ALU_BGEU: 
                begin
                    if (SrcA >= SrcB) Branch_Condition = 1'b1;
                    else Branch_Condition = 1'b0;
                end
            ALU_LUI: Result = SrcB;
            default: Result = 32'hX; // Propagate X to indicate error
        endcase
    end
endmodule