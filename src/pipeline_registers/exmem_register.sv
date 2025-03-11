//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Execute to Memory Pipeline Register                                          
// Description: Holds the control signals, ALU output and other signals to be passed to the memory stage.
//              Uses synchronous reset to ensure a safe state.     
// Author: Luke Shepherd                                                     
// Date Modified: March 2025                                                                                                                                                                                                                                                           
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module exmem_register (
    // Global control signals
    input wire CLK, RST,

    // Control unit signals  
    input wire REG_W_En_E, MEM_W_En_E, 
    input wire [2:0] MEM_Control_E,
    input wire [1:0] Result_Src_Sel_E,

    // Register data
    input wire [4:0] RD_E,
    input wire [31:0] SrcB_Reg_E,

    // ALU output
    input wire [31:0] ALU_Out_E,

    // PC
    input wire [31:0] PC_Plus_4_E,

    // -----------------------------------------------------------
    
    // Control unit signals
    output logic REG_W_En_M, MEM_W_En_M,
    output logic [2:0] MEM_Control_M,
    output logic [1:0] Result_Src_Sel_M,

    // Register data
    output logic [4:0] RD_M,
    output logic [31:0] SrcB_Reg_M,

    // ALU output
    output logic [31:0] ALU_Out_M,

    // PC
    output logic [31:0] PC_Plus_4_M
    );

    always_ff @ (posedge CLK) begin // Synchronous reset 
        REG_W_En_M <= (RST) ? 1'b0 : REG_W_En_E; // If reset ensure no state changing
        MEM_W_En_M <= (RST) ? 1'b0 : MEM_W_En_E;
        MEM_Control_M <= MEM_Control_E;
        Result_Src_Sel_M <= Result_Src_Sel_E;
        RD_M <= RD_E;
        SrcB_Reg_M <= SrcB_Reg_E;
        ALU_Out_M <= ALU_Out_E;
        PC_Plus_4_M <= PC_Plus_4_E;
    end
endmodule