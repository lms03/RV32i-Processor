//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Fetch                                                   
// Description: Holds all decode stage modules.
//              Control Unit: 
//                  Generates control signals using the instruction opcodes.       
//              Register File:
//                  Contains the registers and controls access to them.
// Author: Luke Shepherd                                                     
// Date Created: November 2024                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module decode (

);

endmodule

module control_unit (
    input wire [6:0] OP,
    input wire [2:0] Func3,
    input wire [6:0] Func7,
    output wire REG_W_En, MEM_W_En, Jump_En, Branch_En, 
    output wire [2:0] MEM_Control, // Determines how much memory should be loaded/stored and how it should be extended.
    output wire [3:0] ALU_Control, // Determines what operation the ALU should perform.
    output wire [2:0] Imm_Type_Sel, // Determines how the immediate should be handled.
    output wire Branch_Src_Sel, // Selects the source of the branch target calclulation (PC or Immediate) to allow JALR.
    output wire ALU_SrcA_Sel, ALU_SrcB_Sel, // Selects the ALU sources between registers and PC/Immediate.
    output wire [1:0] Result_Src_Sel // Selects the source of the result, 11 is unused.
    );

    always_comb begin
        // Default values
        REG_W_En = 0; // Don't alter registers
        MEM_W_En = 0; // Don't alter memory
        MEM_Control = MEM_BYTE; 
        Jump_En = 0; // Don't alter control flow
        Branch_En = 0; // Don't alter control flow
        ALU_Control = X;
        Branch_Src_Sel = BRANCH_PC;
        ALU_SrcA_Sel = SRCA_REG;
        ALU_SrcB_Sel = SRCB_REG;
        Imm_Type_Sel = IMM_I;
        Result_Src_Sel = RESULT_ALU;

        case (OP)
            7'b0110011: // R-Type
                begin
                    REG_W_En = 1; // Store result to register
                    ALU_Control = X; // Changed depending on instruction
                    ALU_SrcA_Sel = SRCA_REG; // Select register data
                    ALU_SrcB_Sel = SRCB_REG; // Select register data 
                    Result_Src_Sel = RESULT_ALU; // Select ALU output
                    case (Func3)
                        3'b000: Func7 == 7'b0000000 ? ALU_Control = ?'b??? : ALU_Control = ?'b???; // ADD or SUB
                        3'b001: ALU_Control = ?'b???; //SLL
                        3'b010: ALU_Control = ?'b???; //SLT
                        3'b011: ALU_Control = ?'b???; //SLTU
                        3'b100: ALU_Control = ?'b???; //XOR
                        3'b101: Func7 == 7'b0000000 ? ALU_Control = ?'b??? : ALU_Control = ?'b???; // SRL or SRA
                        3'b110: ALU_Control = ?'b???; //OR
                        3'b111: ALU_Control = ?'b???; //AND
                        default: ALU_Control = X; // Propagate X to highlight error
                    endcase
                end
            7'b0000011, 7'b1100111, 7'b0010011: // I-Type
                begin
                    REG_W_En = 1'b1; // Store result to register
                    MEM_Control = ?'b???; // Changed depending on instruction
                    Jump_En = 0; // Changed depending on if JALR but default to 0 to reduce repetition
                    ALU_Control = X; // Changed depending on instruction
                    Branch_Src_Sel = BRANCH_REG; // JALR Uses register data for target calculation
                    ALU_SrcA_Sel = SRCA_REG; // Select register data
                    ALU_SrcB_Sel = SRCB_IMM; // Select the immediate   
                    Imm_Type_Sel = IMM_I; // I-Type immediate  
                    Result_Src_Sel = RESULT_ALU; // Changed depending on if JALR or not but default to reduce repetition
                    case (func3)
                        3'b000: // JALR, ADDI or LB
                            case (OP)
                                7'b1100111: // JALR
                                    begin
                                        Jump_En = 1'b1; // Enable jump
                                        ALU_Control = ?'b???; // Address calculation uses same operation as ADDI
                                        Result_Src_Sel = RESULT_PC4; // Select PC+4 for result
                                    end
                                7'b0010011, 7'b0000011:  // ADDI and LB
                                    begin
                                        MEM_Control = MEM_BYTE; // Specify byte load for LB
                                        ALU_Control = ?'b???; // Address calculation uses same operation as ADDI
                                    end
                                default: ALU_Control = X; // Propagate X to highlight error
                            endcase
                        3'b001: // LH or SLLI
                            begin
                                OP == 7'b0000011 ? ALU_Control = ?'b??? : ALU_Control = ?'b???;
                                MEM_Control = MEM_HALFWORD; // Specify halfword load
                            end
                        3'b010: // LW or SLTI
                            begin
                                OP == 7'b0000011 ? ALU_Control = ?'b??? : ALU_Control = ?'b???;
                                MEM_Control = MEM_WORD; // Specify word load
                            end
                        3'b011: ALU_Control = ?'b???; // SLTIU
                        3'b100: // LBU or XORI
                            begin
                                OP == 7'b0000011 ? ALU_Control = ?'b??? : ALU_Control = ?'b???;
                                MEM_Control = MEM_BYTE_UNSIGNED; // Specify byte unsigned load
                            end
                        3'b101: // LHU or SRLI or SRAI
                            begin
                                OP == 7'b0000011 ? ALU_Control = ?'b??? : Func7 == 7'b0000000 ? ALU_Control = ?'b??? : ALU_Control = ?'b???;
                                MEM_Control = MEM_HALFWORD; // Specify halfword unsigned load
                            end
                        3'b110: ALU_Control = ?'b???; // ORI
                        3'b111: ALU_Control = ?'b???; // ANDI
                        default: ALU_Control = X; // Propagate X to highlight error
                    endcase
                end
            7'b0100011: // S-Type
                begin
                    MEM_W_En = 1; // Store to memory
                    MEM_Control = X; // Changed depending on amount stored
                    ALU_Control = ?'b???; // Address calculation uses same operation as ADDI
                    ALU_SrcA_Sel = SRCA_REG; // Select register data
                    ALU_SrcB_Sel = SRCB_IMM; // Select the immediate
                    Imm_Type_Sel = IMM_S; // S-Type immediate
                    Result_Src_Sel = RESULT_MEM; // Select memory output
                    case (Func3)
                        3'b000: MEM_Control = ?'b???; // SB
                        3'b001: MEM_Control = ?'b???; // SH
                        3'b010: MEM_Control = ?'b???; // SW
                        default: MEM_Control = X; // Propagate X to highlight error
                    endcase
                end
            7'b1100011: // B-Type
                begin
                    Branch_En = 1; // Enable branch 
                    ALU_Control = X;  // Changed depending on type of branch  
                    ALU_SrcA_Sel = SRCA_REG; // Select register data
                    ALU_SrcB_Sel = SRCB_REG; // Select register data
                    Imm_Type_Sel = IMM_B; // B-Type immediate
                    case (Func3)
                        3'b000: ALU_Control = ?'b???; // BEQ 
                        3'b001: ALU_Control = ?'b???; // BNE
                        3'b100: ALU_Control = ?'b???; // BLT
                        3'b101: ALU_Control = ?'b???; // BGE
                        3'b110: ALU_Control = ?'b???; // BLTU
                        3'b111: ALU_Control = ?'b???; // BGEU
                        default: ALU_Control = X; // Propagate X to highlight error
                    endcase
                end
            7'b0110111, 7'b0010111: // U-Type
                begin
                    REG_W_En = 1; // Result stored in register
                    ALU_Control = ?'b???; // AUIPC uses same as ADDI, LUI uses it's own
                    OP == 0010111 ? ALU_SrcA_Sel = SRCA_PC : ALU_SrcA_Sel = SRCA_REG; // Set depending on if AUIPC or not
                    ALU_SrcB_Sel = SRCB_IMM; // Select immediate
                    Imm_Type_Sel = IMM_U; // U-Type immediate
                    Result_Src_Sel = RESULT_ALU; // Select ALU output
                end
            7'b1101111: // J-Type (JAL Only)
                begin
                    REG_W_En = 1; // Store PC+4 in rd
                    Jump_En = 1; // Enable jump
                    Branch_Src_Sel = BRANCH_PC; // Select PC for target calculation
                    Imm_Type_Sel = IMM_J; // J-Type immediate
                    Result_Src_Sel = RESULT_PC4; // Select PC+4 for result
                end
            7'b0001111, 7'b1110011: // FENCE, PAUSE, ECALL, EBREAK all treated as NOPs, so they use the defaults above to ensure processor state is unchanged
                break;
            default:
                begin
                    REG_W_En = 0; // Don't alter registers
                    MEM_W_En = 0; // Don't alter memory
                    MEM_Control = 0; // Unused
                    Jump_En = 0; // Don't alter control flow
                    Branch_En = 0; // Don't alter control flow
                    ALU_Control = X; // Don't use the ALU
                    ALU_SrcA_Sel = X; // Unused
                    ALU_SrcB_Sel = X; // Unused
                    Imm_Type_Sel = X; // Unused
                    Result_Src_Sel = X; // Unused
                end
        endcase
    end
endmodule

//Consider adding stall signal
module register_file (
    input wire CLK, RST, REG_W_En,
    input wire [4:0] REG_R_Addr1, REG_R_Addr2, REG_W_Addr,
    input wire [31:0] REG_W_Data,
    output wire [31:0] REG_R_Data1, REG_R_Data2
    );

    reg [31:0] registers [31:0];

    always @ (posedge CLK) begin
        if (RST) begin
            for (int i = 0; i < 32; i++)
                registers[i] <= 32'h0;
        end
        else if (REG_W_En && REG_W_Addr != 5'b0)
            registers[REG_W_Addr] <= REG_W_Data;
    end

    assign REG_R_Data1 = registers[REG_R_Addr1];
    assign REG_R_Data2 = registers[REG_R_Addr2];       
endmodule

