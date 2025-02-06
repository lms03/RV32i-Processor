//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Decode to Execute Pipeline Register                                          
// Description: Holds the instruction, control signals and program counters to be passed to the execute stage.
//              Uses synchronous reset and flush.     
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                                           
//////////////////////////////////////////////////////////////////////////////////

module idex_register (
    // Global control signals
    input wire CLK, RST, Flush_D, Stall_En,

    // Control unit signals
    input wire REG_W_En_D, MEM_W_En_D, Jump_En_D, Branch_En_D,
    input wire [2:0] MEM_Control_D,
    input wire [3:0] ALU_Control_D,
    input wire Branch_Src_Sel_D,
    input wire ALU_SrcA_Sel_D, ALU_SrcB_Sel_D,
    input wire [1:0] Result_Src_Sel_D,
    
    // Register data
    input wire [4:0] RD_D, RS1_D, RS2_D,
    input wire [31:0] REG_R_Data1_D, REG_R_Data2_D,

    // Extended Immediate
    input wire [31:0] Imm_Ext_D

    // PC and Instruction
    input wire [31:0] Instr_D, PC_D, PC_Plus_4_D,

    // Control unit signals
    output wire REG_W_En_E, MEM_W_En_E, Jump_En_E, Branch_En_E,
    output wire [2:0] MEM_Control_E,
    output wire [3:0] ALU_Control_E,
    output wire Branch_Src_Sel_E,
    output wire ALU_SrcA_Sel_E, ALU_SrcB_Sel_E,
    output wire [1:0] Result_Src_Sel_E,

    // Register data
    output wire [4:0] RD_E, RS1_E, RS2_E,
    output wire [31:0] REG_R_Data1_E, REG_R_Data2_E,

    // Extended Immediate
    output wire [31:0] Imm_Ext_E

    // PC and Instruction
    output logic [31:0] Instr_E, PC_E, PC_Plus_4_E
    );

    always_ff @ (posedge CLK) begin // Synchronous flush and reset
        if (RST) begin
            Instr_D <= 32'h0;
            PC_D <= 32'h0;
            PC_Plus_4_D <= 32'h0;
        end
        else if (Flush_D) begin // Insert NOP (ADDI x0, x0, 0)
            Instr_D <= 32'h0000_0013;
            PC_D <= 32'h2A2A_2A2A; // Debug pattern for clarity
            PC_Plus_4_D <= 32'h2A2A_2A2A;
        end
        else if (!Stall_En) begin
            Instr_D <= Instr_F;
            PC_D <= PC_F;
            PC_Plus_4_D <= PC_Plus_4_F;
        end
    end
endmodule