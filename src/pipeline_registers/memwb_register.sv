//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Memory to Writeback Pipeline Register                                          
// Description: Holds the control signals, Data output, ALU output and other signals to be passed to the writeback stage.  
//              Uses synchronous reset to ensure a safe state.  
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                                           
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module memwb_register (
    // Global control signals
    input wire CLK, RST,

    // Control unit signals  
    input wire REG_W_En_M,
    input wire [1:0] Result_Src_Sel_M,

    // Register data
    input wire [4:0] RD_M,

    // Data memory
    input wire [31:0] Data_Out_Ext_M,

    // ALU output
    input wire [31:0] ALU_Out_M,

    // PC
    input wire [31:0] PC_Plus_4_M,

    // -----------------------------------------------------------
    
    // Control unit signals
    output logic REG_W_En_W,
    output logic [1:0] Result_Src_Sel_W,

    // Register data
    output logic [4:0] RD_W,

    // Data memory
    output logic [31:0] Data_Out_Ext_W,

    // ALU output
    output logic [31:0] ALU_Out_W,

    // PC
    output logic [31:0] PC_Plus_4_W
    );

    always_ff @ (posedge CLK) begin // Synchronous reset 
        if (RST) begin // Ensure a safe state
            REG_W_En_W <= 1'b0;
        end
        else begin
            REG_W_En_W <= REG_W_En_M;
            Result_Src_Sel_W <= Result_Src_Sel_M;
            RD_W <= RD_M;
            ALU_Out_W <= ALU_Out_M;
            PC_Plus_4_W <= PC_Plus_4_M;
        end
    end

    assign Data_Out_Ext_W = Data_Out_Ext_M; // Bypass the synchronous requirement since it is already synchronously stored into a register
endmodule