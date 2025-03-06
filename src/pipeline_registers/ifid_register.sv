//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Fetch to Decode Pipeline Register                                          
// Description: Holds the instruction and program counters to be passed to the decode stage.
//              Uses synchronous reset and flush.     
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                                           
//////////////////////////////////////////////////////////////////////////////////

module ifid_register (
    input wire CLK, RST, Flush_D, Stall_En,
    input wire PC_F, PC_Plus_4_F,
    input wire Predict_Taken_F,
    output logic [31:0] Instr_D, PC_D, PC_Plus_4_D,
    output logic Predict_Taken_D
    );

    always_ff @ (posedge CLK) begin // Synchronous flush
        if (RST) begin
            Predict_Taken_D <= 1'b0; // Prevent uninitialized values being used in fetch
        end
        else if (Flush_D) begin 
            PC_D <= 32'h2A2A_2A2A; // Debug pattern for clarity
            PC_Plus_4_D <= 32'h2A2A_2A2A;
        end
        else if (!Stall_En) begin
            PC_D <= PC_F;
            PC_Plus_4_D <= PC_Plus_4_F;
            Predict_Taken_D <= Predict_Taken_F;
        end
    end
endmodule