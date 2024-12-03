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
parameter ALU_ADD = 4'b0000; 
parameter ALU_SUB = 4'b0001; 
parameter ALU_AND = 4'b0010; 
parameter ALU_OR = 4'b0011;
parameter ALU_XOR = 4'b0100; 

// ADD, LUI
endpackage