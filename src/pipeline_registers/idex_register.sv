//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Decode to Execute Pipeline Register                                          
// Description: Holds the instruction, control signals and program counters to be passed to the execute stage.
//              Uses synchronous reset and flush.     
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                                           
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module idex_register (
    // Global control signals
    input wire CLK, RST, Flush_E,

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
    input wire [31:0] Imm_Ext_D,

    // PC
    input wire [31:0] PC_D, PC_Plus_4_D,

    // -----------------------------------------------------------
    
    // Control unit signals
    output logic REG_W_En_E, MEM_W_En_E, Jump_En_E, Branch_En_E,
    output logic [2:0] MEM_Control_E,
    output logic [3:0] ALU_Control_E,
    output logic Branch_Src_Sel_E,
    output logic ALU_SrcA_Sel_E, ALU_SrcB_Sel_E,
    output logic [1:0] Result_Src_Sel_E,

    // Register data
    output logic [4:0] RD_E, RS1_E, RS2_E,
    output logic [31:0] REG_R_Data1_E, REG_R_Data2_E,

    // Extended Immediate
    output logic [31:0] Imm_Ext_E,

    // PC
    output logic [31:0] PC_E, PC_Plus_4_E
    );

    always_ff @ (posedge CLK) begin // Synchronous flush and reset 
        if (RST) begin // Ensure a safe state
            REG_W_En_E <= 1'b0; 
            MEM_W_En_E <= 1'b0;
            Jump_En_E <= 1'b0;
            Branch_En_E <= 1'b0;
        end
        else if (Flush_E) begin // Insert NOP (ADDI x0, x0, 0) and set PC for clarity
            REG_W_En_E <= 1'b0; // Disable state changing signals
            MEM_W_En_E <= 1'b0;
            Jump_En_E <= 1'b0;
            Branch_En_E <= 1'b0;
            PC_E <= 32'h2A2A_2A2A; // Debug pattern for clarity
            PC_Plus_4_E <= 32'h2A2A_2A2A;
        end
        else begin
            REG_W_En_E <= REG_W_En_D; 
            MEM_W_En_E <= MEM_W_En_D;
            Jump_En_E <= Jump_En_D;
            Branch_En_E <= Branch_En_D;
            MEM_Control_E <= MEM_Control_D;
            ALU_Control_E <= ALU_Control_D; 
            Branch_Src_Sel_E <= Branch_Src_Sel_D;
            ALU_SrcA_Sel_E <= ALU_SrcA_Sel_D;
            ALU_SrcB_Sel_E <= ALU_SrcB_Sel_D;
            Result_Src_Sel_E <= Result_Src_Sel_D;
            RD_E <= RD_D;
            RS1_E <= RS1_D;
            RS2_E <= RS2_D;
            REG_R_Data1_E <= REG_R_Data1_D;
            REG_R_Data2_E <= REG_R_Data2_D;
            Imm_Ext_E <= Imm_Ext_D;
            PC_E <= PC_D; 
            PC_Plus_4_E <= PC_Plus_4_D;
        end
    end
endmodule