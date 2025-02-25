//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Decode                                                   
// Description: Holds all decode stage modules.
//              Control Unit: 
//                  Generates control signals using the instruction opcodes.       
//              Register File:
//                  Contains the registers and controls access to them.
//              Immediate Extender:
//                  Sign/Zero extends the immediate values to 32-bits based on type.
// Date Modified: February 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module decode (
    input wire CLK, 
    input wire [31:0] Instr_D,

    // Signals from writeback
    input wire REG_W_En_W, 
    input wire [31:0] Result_W,
    input wire [4:0] RD_W,

    // -----------------------------------------------------------
    
    // Control unit signals
    output wire REG_W_En_D, MEM_W_En_D, Jump_En_D, Branch_En_D,
    output wire [2:0] MEM_Control_D,
    output wire [3:0] ALU_Control_D,
    output wire Branch_Src_Sel_D,
    output wire ALU_SrcA_Sel_D, ALU_SrcB_Sel_D,
    output wire [1:0] Result_Src_Sel_D,
    
    // Register data
    output wire [4:0] RD_D, RS1_D, RS2_D,
    output wire [31:0] REG_R_Data1_D, REG_R_Data2_D,

    // Extended immediate
    output wire [31:0] Imm_Ext_D
    );

    wire [2:0] Imm_Type_Sel; 

    control_unit control_unit (
        .OP(Instr_D[6:0]),
        .Func3(Instr_D[14:12]),
        .Func7(Instr_D[31:25]),
        .REG_W_En(REG_W_En_D),
        .MEM_W_En(MEM_W_En_D),
        .Jump_En(Jump_En_D),
        .Branch_En(Branch_En_D),
        .MEM_Control(MEM_Control_D),
        .ALU_Control(ALU_Control_D),
        .Imm_Type_Sel(Imm_Type_Sel),
        .Branch_Src_Sel(Branch_Src_Sel_D),
        .ALU_SrcA_Sel(ALU_SrcA_Sel_D),
        .ALU_SrcB_Sel(ALU_SrcB_Sel_D),
        .Result_Src_Sel(Result_Src_Sel_D)
    );

    register_file reg_file (
        .CLK(CLK),
        .REG_W_En(REG_W_En_W),  
        .REG_R_Addr1(Instr_D[19:15]),
        .REG_R_Addr2(Instr_D[24:20]),
        .REG_W_Addr(RD_W),  
        .REG_W_Data(Result_W),  
        .REG_R_Data1(REG_R_Data1_D),
        .REG_R_Data2(REG_R_Data2_D)
    );

    immediate_extender imm_extender (
        .Instr(Instr_D),
        .Imm_Type_Sel(Imm_Type_Sel),
        .Imm_Ext(Imm_Ext_D)
    );

    assign RD_D  = Instr_D[11:7];   // Destination register
    assign RS1_D = Instr_D[19:15];  // Source register 1 (For hazard unit)
    assign RS2_D = Instr_D[24:20];  // Source register 2 (For hazard unit)

endmodule

module control_unit (
    input wire [6:0] OP,
    input wire [2:0] Func3,
    input wire [6:0] Func7,
    output logic REG_W_En, MEM_W_En, Jump_En, Branch_En, 
    output logic [2:0] MEM_Control, // Determines how much memory should be loaded/stored and how it should be extended.
    output logic [3:0] ALU_Control, // Determines what operation the ALU should perform.
    output logic [2:0] Imm_Type_Sel, // Determines how the immediate should be handled.
    output logic Branch_Src_Sel, // Selects the input of the branch target calclulation (PC or Immediate) to allow JALR.
    output logic ALU_SrcA_Sel, ALU_SrcB_Sel, // Selects the ALU inputs between registers and PC/Immediate.
    output logic [1:0] Result_Src_Sel // Selects the source of the result, 11 is unused.
    );

    always_comb begin
        // Default values
        REG_W_En = 0; // Don't alter registers
        MEM_W_En = 0; // Don't alter memory
        MEM_Control = MEM_BYTE; 
        Jump_En = 0; // Don't alter control flow
        Branch_En = 0; // Don't alter control flow
        Branch_Src_Sel = BRANCH_PC;
        ALU_Control = ALU_ADD;
        ALU_SrcA_Sel = SRCA_REG;
        ALU_SrcB_Sel = SRCB_REG;
        Imm_Type_Sel = IMM_I;
        Result_Src_Sel = RESULT_ALU;

        case (OP)
            OP_R_TYPE:
                begin
                    // R-Type defaults
                    REG_W_En = 1; // Store result to register
                    ALU_SrcA_Sel = SRCA_REG; // Select register data
                    ALU_SrcB_Sel = SRCB_REG; // Select register data 
                    Result_Src_Sel = RESULT_ALU; // Select ALU output
                    case (Func3)
                        F3_R_ADD_SUB: ALU_Control = (Func7 == F7_R_ADD) ? ALU_ADD : ALU_SUB; 
                        F3_R_SLL: ALU_Control = ALU_SLL; 
                        F3_R_SLT: ALU_Control = ALU_BLT; // SLT uses same as BLT
                        F3_R_SLTU: ALU_Control = ALU_BLTU; // SLTU uses same as BLTU
                        F3_R_XOR: ALU_Control = ALU_XOR; 
                        F3_R_SRL_SRA: ALU_Control = (Func7 == F7_R_SRL) ? ALU_SRL : ALU_SRA;
                        F3_R_OR: ALU_Control = ALU_OR; 
                        F3_R_AND: ALU_Control = ALU_AND; 
                        default: ALU_Control = 4'hX; // Propagate X to highlight error
                    endcase
                end
            OP_I_TYPE_LOAD, OP_JALR, OP_I_TYPE:
                begin
                    // I-Type defaults
                    REG_W_En = 1'b1; // Store result to register
                    ALU_SrcA_Sel = SRCA_REG; // Select register data
                    ALU_SrcB_Sel = SRCB_IMM; // Select the immediate   
                    Imm_Type_Sel = IMM_I; // I-Type immediate  
                    Result_Src_Sel = RESULT_ALU; // Changed depending on if JALR or not but default to reduce repetition
                    case (Func3)
                        F3_I_JALR_ADDI_LB: // JALR, ADDI or LB
                            case (OP)
                                OP_JALR: // JALR
                                    begin
                                        Jump_En = 1'b1; // Enable jump
                                        Branch_Src_Sel = BRANCH_REG; // JALR Uses register data for target calculation
                                        Result_Src_Sel = RESULT_PC4; // Select PC+4 for result
                                    end
                                OP_I_TYPE, OP_I_TYPE_LOAD:  // ADDI and LB
                                    begin
                                        MEM_Control = MEM_BYTE; // Specify byte load for LB
                                        ALU_Control = ALU_ADD; // Load address calculation uses same operation as ADDI
                                    end
                                default: ALU_Control = 4'hX; // Propagate X to highlight error
                            endcase
                        F3_I_LH_SLLI: // LH or SLLI
                            begin
                                ALU_Control = (OP == OP_I_TYPE_LOAD) ? ALU_ADD : ALU_SLL;
                                MEM_Control = MEM_HALFWORD; // Specify halfword load
                            end
                        F3_I_LW_SLTI: // LW or SLTI
                            begin
                                ALU_Control = (OP == OP_I_TYPE_LOAD) ? ALU_ADD : ALU_BLT; // SLTI uses same as BLT
                                MEM_Control = MEM_WORD; // Specify word load
                            end
                        F3_I_SLTIU: ALU_Control = ALU_BLTU; // SLTIU uses same as BLTU
                        F3_I_LBU_XORI: // LBU or XORI
                            begin
                                ALU_Control = (OP == OP_I_TYPE_LOAD) ? ALU_ADD : ALU_XOR;
                                MEM_Control = MEM_BYTE_UNSIGNED; // Specify byte unsigned load
                            end
                        F3_I_LHU_SRLI_SRAI: // LHU or SRLI or SRAI
                            begin
                                ALU_Control = (OP == OP_I_TYPE_LOAD) ? ALU_ADD : ((Func7 == F7_I_SRLI) ? ALU_SRL : ALU_SRA);
                                MEM_Control = MEM_HALFWORD; // Specify halfword unsigned load
                            end
                        F3_I_ORI: ALU_Control = ALU_OR; // ORI
                        F3_I_ANDI: ALU_Control = ALU_AND; // ANDI
                        default: ALU_Control = 4'hX; // Propagate X to highlight error
                    endcase
                end
            OP_S_TYPE:
                begin
                    // S-Type defaults
                    MEM_W_En = 1; // Store to memory
                    ALU_Control = ALU_ADD; // Address calculation uses same operation as ADD
                    ALU_SrcA_Sel = SRCA_REG; // Select register data
                    ALU_SrcB_Sel = SRCB_IMM; // Select the immediate
                    Imm_Type_Sel = IMM_S; // S-Type immediate
                    case (Func3)
                        F3_S_SB: MEM_Control = MEM_BYTE; // SB, Specify byte store
                        F3_S_SH: MEM_Control = MEM_HALFWORD; // SH, Specify halfword store
                        F3_S_SW: MEM_Control = MEM_WORD; // SW, Specify word store
                        default: MEM_Control = 3'bX; // Propagate X to highlight error
                    endcase
                end
            OP_B_TYPE:
                begin
                    // B-Type defaults
                    Branch_En = 1; // Enable branch 
                    ALU_SrcA_Sel = SRCA_REG; // Select register data
                    ALU_SrcB_Sel = SRCB_REG; // Select register data
                    Branch_Src_Sel = BRANCH_PC; // Branches use PC for target calculation
                    Imm_Type_Sel = IMM_B; // B-Type immediate
                    case (Func3)
                        F3_B_BEQ: ALU_Control = ALU_BEQ; 
                        F3_B_BNE: ALU_Control = ALU_BNE; 
                        F3_B_BLT: ALU_Control = ALU_BLT; 
                        F3_B_BGE: ALU_Control = ALU_BGE; 
                        F3_B_BLTU: ALU_Control = ALU_BLTU; 
                        F3_B_BGEU: ALU_Control = ALU_BGEU; 
                        default: ALU_Control = 4'hX; // Propagate X to highlight error
                    endcase
                end
            OP_LUI, OP_AUIPC:
                begin
                    REG_W_En = 1; // Result stored in register
                    ALU_Control = (OP == OP_AUIPC) ? ALU_ADD : ALU_LUI; // AUIPC uses same as ADD, LUI uses it's own
                    ALU_SrcA_Sel = (OP == OP_AUIPC) ? SRCA_PC : SRCA_REG; // Set depending on if AUIPC or not
                    ALU_SrcB_Sel = SRCB_IMM; // Select immediate
                    Imm_Type_Sel = IMM_U; // U-Type immediate
                    Result_Src_Sel = RESULT_ALU; // Select ALU output
                end
            OP_J_TYPE:
                begin
                    REG_W_En = 1; // Store PC+4 in rd
                    Jump_En = 1; // Enable jump
                    Branch_Src_Sel = BRANCH_PC; // Select PC for target calculation
                    Imm_Type_Sel = IMM_J; // J-Type immediate
                    Result_Src_Sel = RESULT_PC4; // Select PC+4 for result
                end
            OP_FENCE_PAUSE, OP_ECALL_EBREAK: // FENCE, PAUSE, ECALL, EBREAK all treated as NOPs, so they use the defaults above to ensure processor state is unchanged
                break;
            default: // Illegal/Unsupported instruction so ensure processor state is unchanged
                begin
                    REG_W_En = 0; // Don't alter registers
                    MEM_W_En = 0; // Don't alter memory
                    Jump_En = 0; // Don't alter control flow
                    Branch_En = 0; // Don't alter control flow
                end
        endcase
    end
endmodule

module register_file (
    input wire CLK, REG_W_En,
    input wire [4:0] REG_R_Addr1, REG_R_Addr2, REG_W_Addr,
    input wire [31:0] REG_W_Data,
    output logic [31:0] REG_R_Data1, REG_R_Data2
    );

    reg [31:0] registers [0:31];

    always_ff @ (negedge CLK) begin // Write on falling edge to allow read by the time the rising edge comes
        if (REG_W_En && REG_W_Addr != 5'h0) // Prevent write to x0
            registers[REG_W_Addr] <= REG_W_Data;
    end

    always_comb begin
        REG_R_Data1 = (REG_R_Addr1 != 0) ? registers[REG_R_Addr1] : 32'b0; // Ensure x0 is always read as 0, necessary in the absence of a reset signal
        REG_R_Data2 = (REG_R_Addr2 != 0) ? registers[REG_R_Addr2] : 32'b0;  
    end    
endmodule

module immediate_extender ( 
    input wire [31:0] Instr, // Uses entire instruction as input to cover all immediate variants
    input wire [2:0] Imm_Type_Sel, // Output from decoder, chooses how to extend
    output logic [31:0] Imm_Ext  // The output 32-bit immediate for later use
    );

    always_comb begin
        case (Imm_Type_Sel)
            IMM_I: Imm_Ext = {{21{Instr[31]}}, Instr[30:20]}; // Sign extend 12-bit immediate using the MSB
            IMM_S: Imm_Ext = {{21{Instr[31]}}, Instr[30:25], Instr[11:7]}; // Sign extend 12-bit broken up immediate using the MSB
            IMM_B: Imm_Ext = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0}; // Sign extend 12-bit broken up immediate using the MSB in B-Type format
            IMM_U: Imm_Ext = {Instr[31:12], 12'h0}; // Zero extend 20-bit immediate
            IMM_J: Imm_Ext = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0}; // Sign extend 20-bit immediate using the MSB in J-Type format
            default: Imm_Ext = 32'hX; // Propagate X to highlight error (Consider replacing for synthesis)
        endcase
    end
endmodule