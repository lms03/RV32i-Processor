//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Fetch to Decode Pipeline Register                                          
// Description: Holds the instruction and program counter to be passed to the decode stage.
//              Uses synchronous reset and flush.     
// Author: Luke Shepherd                                                     
// Date Modified: December 2024                                                                                                                                                                                                                                                           
//////////////////////////////////////////////////////////////////////////////////

module ifid_register (
    input wire CLK, RST, Flush_D, Stall_En,
    input wire [31:0] Instr_F, PC_F, PC_Plus_4_F,
    output logic [31:0] Instr_D, PC_D, PC_Plus_4_D
    );

    always_ff @ (posedge CLK) begin // Synchronous flush and reset
        if (RST) begin
            Instr_D <= 32'h0;
            PC_D <= 32'h0;
            PC_Plus_4_D <= 32'h0;
        end
        else if (Flush_D) begin // Insert NOP (ADDI x0, x0, 0)
            Instr_D <= 32'h00000013;
            PC_D <= 32'h0; // Perhaps should set this to something else, such as a debug pattern for clarity
            PC_Plus_4_D <= 32'h0;
        end
        else if (!Stall_En) begin
            Instr_D <= Instr_F;
            PC_D <= PC_F;
            PC_Plus_4_D <= PC_Plus_4_F;
        end
    end
endmodule