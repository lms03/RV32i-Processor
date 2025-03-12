//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Definitions                                      
// Description: Contains localparams in order to make code more readable.
// Author: Luke Shepherd                                                     
// Date Modified: March 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

package definitions;
// Generic
localparam int CLOCK_PERIOD = 100; // 10 MHz

// MEM_Control localparams
localparam MEM_BYTE = 3'b000;
localparam MEM_HALFWORD = 3'b001;
localparam MEM_WORD = 3'b010;
localparam MEM_BYTE_UNSIGNED = 3'b011;
localparam MEM_HALFWORD_UNSIGNED = 3'b100;

// Imm_Type_Sel localparams
localparam IMM_I = 3'b000;
localparam IMM_S = 3'b001;
localparam IMM_B = 3'b010;
localparam IMM_U = 3'b011;
localparam IMM_J = 3'b100;

// Result_Src_Sel localparams
localparam RESULT_ALU = 2'b00;
localparam RESULT_MEM = 2'b01;
localparam RESULT_PC4 = 2'b10;

// Branch_Src_Sel localparams;
localparam BRANCH_PC = 1'b0;
localparam BRANCH_REG = 1'b1;

// ALU_SrcA_Sel localparams
localparam SRCA_REG = 1'b0;
localparam SRCA_PC = 1'b1;

// ALU_SrcB_Sel localparams
localparam SRCB_REG = 1'b0;
localparam SRCB_IMM = 1'b1;

// FWD_SrcA/B localparams
localparam FWD_NONE = 2'b00; 
localparam FWD_MEM = 2'b01;  // Result from ALU in Memory stage
localparam FWD_WB = 2'b10;   // Final result from Writeback stage

// Branch_Taken localparams
localparam BRANCH_NOT_TAKEN = 1'b0;
localparam BRANCH_TAKEN = 1'b1;

// Predict_Taken localparams
localparam PREDICT_NOT_TAKEN = 1'b0;
localparam PREDICT_TAKEN = 1'b1;

// Branch_State localparams
localparam STRONGLY_UNTAKEN = 2'b00;
localparam WEAKLY_UNTAKEN = 2'b01;
localparam WEAKLY_TAKEN = 2'b10;
localparam STRONGLY_TAKEN = 2'b11;

// ALU Control Signals
localparam ALU_ADD = 4'b0000; // Add SrcA and SrcB - ADD(I), L(B/H/W), S(B/H/W), AUIPC
localparam ALU_SUB = 4'b0001; // Subtract SrcA and SrcB - SUB 
localparam ALU_AND = 4'b0010; // Bitwise logical AND on SrcA and SrcB - AND(I) 
localparam ALU_OR = 4'b0011; // Bitwise logical OR on SrcA and SrcB - OR(I)
localparam ALU_XOR = 4'b0100; // Bitwise logical XOR on SrcA and SrcB - XOR(I)
localparam ALU_SLL = 4'b0101; // Left shift by SrcB[4:0] and zero extend - SLL(I)
localparam ALU_SRL = 4'b0110; // Right shift by SrcB[4:0] and zero extend - SRL(I)
localparam ALU_SRA = 4'b0111; // Right shift by SrcB[4:0] and sign extend - SRA(I)
localparam ALU_BEQ = 4'b1000; // Subtract SrcA and SrcB, set branch to 1 if equal - BEQ
localparam ALU_BNE = 4'b1001; // Subtract SrcA and SrcB, set branch to 1 if not equal - BNE
localparam ALU_BLT = 4'b1010; // Subtract SrcA and SrcB, set branch and result to 1 if negative - BLT, SLT
localparam ALU_BLTU = 4'b1011; // (Unsigned) Subtract SrcA and SrcB, set branch and result to 1 if negative - BLTU, SLTU
localparam ALU_BGE = 4'b1100; // Subtract SrcA and SrcB, set branch to 1 if not negative - BGE
localparam ALU_BGEU = 4'b1101; // (Unsigned) Subtract SrcA and SrcB, set branch to 1 if not negative - BGEU
localparam ALU_LUI = 4'b1110; // Writes SrcB (Immediate) as result to RD - LUI

// Opcode localparams
localparam OP_LUI = 7'b0110111;
localparam OP_AUIPC = 7'b0010111;
localparam OP_J_TYPE = 7'b1101111;
localparam OP_JALR = 7'b1100111;
localparam OP_B_TYPE = 7'b1100011;
localparam OP_I_TYPE_LOAD = 7'b0000011; 
localparam OP_I_TYPE = 7'b0010011; 
localparam OP_S_TYPE = 7'b0100011; 
localparam OP_R_TYPE = 7'b0110011; 
localparam OP_FENCE_PAUSE = 7'b0001111;
localparam OP_ECALL_EBREAK = 7'b1110011;

// Func3 R-Type localparams
localparam F3_R_ADD_SUB = 3'b000;
localparam F3_R_SLL = 3'b001;
localparam F3_R_SLT = 3'b010;
localparam F3_R_SLTU = 3'b011;
localparam F3_R_XOR = 3'b100;
localparam F3_R_SRL_SRA = 3'b101;
localparam F3_R_OR = 3'b110;
localparam F3_R_AND = 3'b111;

// Func3 I-Type localparams
localparam F3_I_JALR_ADDI_LB = 3'b000;
localparam F3_I_LH_SLLI = 3'b001;
localparam F3_I_LW_SLTI = 3'b010;
localparam F3_I_SLTIU = 3'b011;
localparam F3_I_LBU_XORI = 3'b100;
localparam F3_I_LHU_SRLI_SRAI = 3'b101;
localparam F3_I_ORI = 3'b110;
localparam F3_I_ANDI = 3'b111;

// Func3 S-Type localparams
localparam F3_S_SB = 3'b000;
localparam F3_S_SH = 3'b001;
localparam F3_S_SW = 3'b010;

// Func3 B-Type localparams
localparam F3_B_BEQ = 3'b000;
localparam F3_B_BNE = 3'b001;
localparam F3_B_BLT = 3'b100;
localparam F3_B_BGE = 3'b101;
localparam F3_B_BLTU = 3'b110;
localparam F3_B_BGEU = 3'b111;

// Func7 R-Type localparams
localparam F7_R_ADD = 7'b0000000;
localparam F7_R_SRL = 7'b0000000;
localparam F7_R_MUL = 7'b0000001;

// Func7 I-Type localparams
localparam F7_I_SRLI = 7'b0000000;
endpackage