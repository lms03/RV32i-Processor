//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Memory                                                   
// Description: Holds all Memory stage modules.
//              Data Memory: 
//                  Holds the data for the program to operate on and allows read/writes. Follows a single-port BRAM template.
// Author: Luke Shepherd
// Date Modified: February 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module memory (
    input wire CLK,

    // Control unit signals
    input wire MEM_W_En_M,
    input wire [2:0] MEM_Control_M,

    // Register data
    input wire [31:0] REG_R_Data2_M,

    // ALU output
    input wire [31:0] ALU_Out_M,

    // -----------------------------------------------------------
    
    // Outputs
    output wire [31:0] Data_Out_Ext_M
    );

    data_memory data_memory (
        .CLK(CLK),
        .MEM_W_En(MEM_W_En_M),
        .MEM_Control(MEM_Control_M),
        .RW_Addr(ALU_Out_M),
        .W_Data(REG_R_Data2_M),
        .R_Data(Data_Out_Ext_M)
    );

endmodule

module data_memory (
    input wire CLK, MEM_W_En,
    input wire [2:0] MEM_Control,
    input wire [31:0] RW_Addr, W_Data,
    output logic [31:0] R_Data
    );

    wire [7:0] byte0, byte1, byte2, byte3;             // Byte reads from each memory
    wire [7:0] W_Data0, W_Data1, W_Data2, W_Data3;     // Data to be written to each memory
    wire MEM_W_En0, MEM_W_En1, MEM_W_En2, MEM_W_En3;   // Write enables for each memory
    
    assign MEM_W_En0 = MEM_W_En && ((MEM_Control == MEM_BYTE && RW_Addr[1:0] == 2'b00) || 
                                    (MEM_Control == MEM_HALFWORD && RW_Addr[1] == 1'b0) || 
                                    (MEM_Control == MEM_WORD));
    assign MEM_W_En1 = MEM_W_En && ((MEM_Control == MEM_BYTE && RW_Addr[1:0] == 2'b01) || 
                                    (MEM_Control == MEM_HALFWORD && RW_Addr[1] == 1'b0) || 
                                    (MEM_Control == MEM_WORD));
    assign MEM_W_En2 = MEM_W_En && ((MEM_Control == MEM_BYTE && RW_Addr[1:0] == 2'b10) || 
                                    (MEM_Control == MEM_HALFWORD && RW_Addr[1] == 1'b1) || 
                                    (MEM_Control == MEM_WORD));
    assign MEM_W_En3 = MEM_W_En && ((MEM_Control == MEM_BYTE && RW_Addr[1:0] == 2'b11) || 
                                    (MEM_Control == MEM_HALFWORD && RW_Addr[1] == 1'b1) || 
                                    (MEM_Control == MEM_WORD));

    assign W_Data0 = W_Data[7:0];
    assign W_Data1 = (MEM_Control == MEM_BYTE) ? W_Data[7:0] : W_Data[15:8];
    assign W_Data2 = (MEM_Control == MEM_WORD) ? W_Data[23:16] : W_Data[7:0];
    assign W_Data3 = (MEM_Control == MEM_BYTE) ? W_Data[7:0] : (MEM_Control == MEM_HALFWORD) ? W_Data[15:8] : W_Data[31:24];

    byte_memory memory0 (
        .CLK(CLK),
        .MEM_W_En(MEM_W_En0),
        .RW_Addr(RW_Addr[9:2]),
        .W_Data(W_Data0),
        .R_Data(byte0)
    );

    byte_memory memory1 (
        .CLK(CLK),
        .MEM_W_En(MEM_W_En1),
        .RW_Addr(RW_Addr[9:2]),
        .W_Data(W_Data1),
        .R_Data(byte1)
    );

    byte_memory memory2 (
        .CLK(CLK),
        .MEM_W_En(MEM_W_En2),
        .RW_Addr(RW_Addr[9:2]),
        .W_Data(W_Data2),
        .R_Data(byte2)
    );

    byte_memory memory3 (
        .CLK(CLK),
        .MEM_W_En(MEM_W_En3),
        .RW_Addr(RW_Addr[9:2]),
        .W_Data(W_Data3),
        .R_Data(byte3)
    );

    always_comb begin
        case (MEM_Control)
            MEM_BYTE: 
                case (RW_Addr[1:0])
                    2'b00: R_Data = {{24{byte0[7]}}, byte0};
                    2'b01: R_Data = {{24{byte1[7]}}, byte1};
                    2'b10: R_Data = {{24{byte2[7]}}, byte2};
                    default: R_Data = {{24{byte3[7]}}, byte3};
                endcase
            MEM_BYTE_UNSIGNED: 
                case (RW_Addr[1:0])
                    2'b00: R_Data = {24'b0, byte0};
                    2'b01: R_Data = {24'b0, byte1};
                    2'b10: R_Data = {24'b0, byte2};
                    default: R_Data = {24'b0, byte3};
                endcase
            MEM_HALFWORD:
                case (RW_Addr[1])
                    1'b0: R_Data = {{16{byte1[7]}}, byte1, byte0};
                    default: R_Data = {{16{byte3[7]}}, byte3, byte2};
                endcase
            MEM_HALFWORD_UNSIGNED: 
                case (RW_Addr[1])
                    1'b0: R_Data = {16'b0, byte1, byte0};
                    default: R_Data = {16'b0, byte3, byte2};
                endcase
            MEM_WORD: R_Data = {byte3, byte2, byte1, byte0};
            default: R_Data = 32'b0;
        endcase
    end
endmodule

module byte_memory (
    input wire CLK, MEM_W_En, 
    input wire [7:0] RW_Addr, 
    input wire [7:0] W_Data, 
    output logic [7:0] R_Data
    );

    logic [7:0] memory [0:255]; // 256x1 bytes of memory
    
    always_ff @ (posedge CLK) begin // Single port BRAM template
        if (MEM_W_En) memory[RW_Addr[7:0]] <= W_Data[7:0];
        R_Data <= memory[RW_Addr];
    end   
endmodule