//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Definitions                                      
// Description: Contains parameters in order to make code more readable.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

package definitions;
// Generic
parameter int CLOCK_PERIOD = 100; // 10 MHz

// MEM_Control parameters
parameter MEM_BYTE = 3'b000;
parameter MEM_HALFWORD = 3'b001;
parameter MEM_WORD = 3'b010;
parameter MEM_BYTE_UNSIGNED = 3'b100;
parameter MEM_HALFWORD_UNSIGNED = 3'b101;

// Imm_Type_Sel parameters
parameter IMM_I = 3'b000;
parameter IMM_S = 3'b001;
parameter IMM_B = 3'b010;
parameter IMM_U = 3'b011;
parameter IMM_J = 3'b100;

// Result_Src_Sel parameters
parameter RESULT_ALU = 2'b00;
parameter RESULT_MEM = 2'b01;
parameter RESULT_PC4 = 2'b10;

// Branch_Src_Sel parameters;
parameter BRANCH_PC = 1'b0;
parameter BRANCH_REG = 1'b1;

// ALU_SrcA_Sel parameters
parameter SRCA_REG = 1'b0;
parameter SRCA_PC = 1'b1;

// ALU_SrcB_Sel parameters
parameter SRCB_REG = 1'b0;
parameter SRCB_IMM = 1'b1;

// ALU Control Signals
parameter ALU_ADD = 4'b0000; // Add SrcA and SrcB - ADD(I), L(B/H/W), S(B/H/W), AUIPC
parameter ALU_SUB = 4'b0001; // Subtract SrcA and SrcB - SUB 
parameter ALU_AND = 4'b0010; // Bitwise logical AND on SrcA and SrcB - AND(I) 
parameter ALU_OR = 4'b0011; // Bitwise logical OR on SrcA and SrcB - OR(I)
parameter ALU_XOR = 4'b0100; // Bitwise logical XOR on SrcA and SrcB - XOR(I)
parameter ALU_SLL = 4'b0101; // Left shift by SrcB[4:0] and zero extend - SLL(I)
parameter ALU_SRL = 4'b0110; // Right shift by SrcB[4:0] and zero extend - SRL(I)
parameter ALU_SRA = 4'b0111; // Right shift by SrcB[4:0] and sign extend - SRA(I)
parameter ALU_BEQ = 4'b1000; // Subtract SrcA and SrcB, set branch to 1 if equal - BEQ
parameter ALU_BNE = 4'b1001; // Subtract SrcA and SrcB, set branch to 1 if not equal - BNE
parameter ALU_BLT = 4'b1010; // Subtract SrcA and SrcB, set branch and result to 1 if negative - BLT, SLT
parameter ALU_BLTU = 4'b1011; // (Unsigned) Subtract SrcA and SrcB, set branch and result to 1 if negative - BLTU, SLTU
parameter ALU_BGE = 4'b1100; // Subtract SrcA and SrcB, set branch to 1 if not negative - BGE
parameter ALU_BGEU = 4'b1101; // (Unsigned) Subtract SrcA and SrcB, set branch to 1 if not negative - BGEU
parameter ALU_LUI = 4'b1110; // Writes SrcB (Immediate) as result to RD - LUI

// Opcode parameters
parameter OP_LUI = 7'b0110111;
parameter OP_AUIPC = 7'b0010111;
parameter OP_J_TYPE = 7'b1101111;
parameter OP_JALR = 7'b1100111;
parameter OP_B_TYPE = 7'b1100011;
parameter OP_I_TYPE_LOAD = 7'b0000011;
parameter OP_I_TYPE = 7'b0010011;
parameter OP_S_TYPE = 7'b0100011;
parameter OP_R_TYPE = 7'b0110011;
parameter OP_FENCE_PAUSE = 7'b0001111;
parameter OP_ECALL_EBREAK = 7'b1110011;

// Func3 R-Type parameters
parameter F3_R_ADD_SUB = 3'b000;
parameter F3_R_SLL = 3'b001;
parameter F3_R_SLT = 3'b010;
parameter F3_R_SLTU = 3'b011;
parameter F3_R_XOR = 3'b100;
parameter F3_R_SRL_SRA = 3'b101;
parameter F3_R_OR = 3'b110;
parameter F3_R_AND = 3'b111;

// Func3 I-Type parameters
parameter F3_I_JALR_ADDI_LB = 3'b000;
parameter F3_I_LH_SLLI = 3'b001;
parameter F3_I_LW_SLTI = 3'b010;
parameter F3_I_SLTIU = 3'b011;
parameter F3_I_LBU_XORI = 3'b100;
parameter F3_I_LHU_SRLI_SRAI = 3'b101;
parameter F3_I_ORI = 3'b110;
parameter F3_I_ANDI = 3'b111;

// Func3 S-Type parameters
parameter F3_S_SB = 3'b000;
parameter F3_S_SH = 3'b001;
parameter F3_S_SW = 3'b010;

// Func3 B-Type parameters
parameter F3_B_BEQ = 3'b000;
parameter F3_B_BNE = 3'b001;
parameter F3_B_BLT = 3'b100;
parameter F3_B_BGE = 3'b101;
parameter F3_B_BLTU = 3'b110;
parameter F3_B_BGEU = 3'b111;

// Func7 R-Type parameters
parameter F7_R_ADD = 7'b0000000;
parameter F7_R_SRL = 7'b0000000;

// Func7 I-Type parameters
parameter F7_I_SRLI = 7'b0000000;
endpackage