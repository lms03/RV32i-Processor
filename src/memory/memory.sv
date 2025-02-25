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
    output wire [31:0] MEM_Out_M
    );

    data_memory data_memory (
        .CLK(CLK),
        .MEM_W_En(MEM_W_En_M),
        .MEM_Control(MEM_Control_M),
        .RW_Addr(ALU_Out_M),
        .W_Data(REG_R_Data2_M),
        .R_Data(MEM_Out_M)
    );

endmodule

module data_memory (
    input wire CLK, MEM_W_En, 
    input wire [2:0] MEM_Control,
    input wire [31:0] RW_Addr, W_Data, // Consider declaring RW_Addr as 8 bits
    output logic [31:0] R_Data
    );

    logic [7:0] memory [0:255]; // 256 bytes of memory

    always_ff @ (posedge CLK) begin
        if (MEM_W_En) begin
            case (MEM_Control)
                MEM_BYTE: memory[RW_Addr[7:0]] <= W_Data[7:0];  
                MEM_HALFWORD: 
                    begin
                        memory[RW_Addr[7:0]] <= W_Data[7:0]; 
                        memory[RW_Addr[7:0] + 1] <= W_Data[15:8];    
                    end
                MEM_WORD: 
                    begin
                        memory[RW_Addr[7:0]] <= W_Data[7:0]; 
                        memory[RW_Addr[7:0] + 1] <= W_Data[15:8];              
                        memory[RW_Addr[7:0] + 2] <= W_Data[23:16];             
                        memory[RW_Addr[7:0] + 3] <= W_Data[31:24];             
                    end
                default: memory[RW_Addr[7:0]] <= memory[RW_Addr[7:0]]; // Do nothing
            endcase
        end   

        case (MEM_Control)
            MEM_BYTE: R_Data <= {{24{memory[RW_Addr[7:0]][7]}}, memory[RW_Addr[7:0]]}; // Sign extended
            MEM_BYTE_UNSIGNED: R_Data <= {24'h0, memory[RW_Addr[7:0]]}; // Zero extended
            MEM_HALFWORD: R_Data <= {{16{memory[RW_Addr[7:0] + 1][7]}}, memory[RW_Addr[7:0] + 1], memory[RW_Addr[7:0]]};
            MEM_HALFWORD_UNSIGNED: R_Data <= {16'h0, memory[RW_Addr[7:0] + 1], memory[RW_Addr[7:0]]};
            MEM_WORD: R_Data <= {memory[RW_Addr[7:0] + 3], memory[RW_Addr[7:0] + 2], memory[RW_Addr[7:0] + 1], memory[RW_Addr[7:0]]};
            default: R_Data <= 32'h0;
        endcase
    end
endmodule
