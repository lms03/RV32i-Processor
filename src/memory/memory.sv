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

module memory ();
endmodule

module data_memory (
    input wire CLK, MEM_W_En, 
    input wire [2:0] MEM_Control,
    input wire [31:0] RW_Addr, W_Data,
    output logic [31:0] Data_Out
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
            MEM_BYTE: Data_Out <= {{24{memory[RW_Addr[7:0]][7]}}, memory[RW_Addr[7:0]]}; // Sign extended
            MEM_BYTE_UNSIGNED: Data_Out <= {24'h0, memory[RW_Addr[7:0]]}; // Zero extended
            MEM_HALFWORD: Data_Out <= {{16{memory[RW_Addr[7:0] + 1][7]}}, memory[RW_Addr[7:0] + 1], memory[RW_Addr[7:0]]};
            MEM_HALFWORD_UNSIGNED: Data_Out <= {16'h0, memory[RW_Addr[7:0] + 1], memory[RW_Addr[7:0]]};
            MEM_WORD: Data_Out <= {memory[RW_Addr[7:0] + 3], memory[RW_Addr[7:0] + 2], memory[RW_Addr[7:0] + 1], memory[RW_Addr[7:0]]};
            default: Data_Out <= 32'h0;
        endcase
    end
endmodule
