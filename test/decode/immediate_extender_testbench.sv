//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Immediate Extender Testbench                                                   
// Description: This is a testbench to ensure that the immediate extender appropriately extends immediate values based on the instruction type.
// Author: Luke Shepherd                                                     
// Date Modified: January 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module immediate_extender_testbench;
    logic CLK; // Wrap module with a clock to control the sim more easily and better represent the external system
    logic [31:0] Instr;
    logic [2:0] Imm_Type_Sel;
    logic [31:0] Imm_Ext;

    immediate_extender iext (
        .Instr(Instr),
        .Imm_Type_Sel(Imm_Type_Sel),
        .Imm_Ext(Imm_Ext)
    );

    logic [31:0] Expected; // The immediate output that is expected

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        @(posedge CLK); // Wait for first posedge before starting
        Instr <= 32'h2A2A_2A2A; // Initialize instruction for first manual check
        Imm_Type_Sel <= IMM_I; // Initialize type to I-type
        Expected <= 32'h0000_02A2; // Expected immediate value for the instruction (Last 12 bits of the instruction with sign extension)
        @(posedge CLK);
        
        Imm_Type_Sel <= IMM_B; // Initialize type to B-type to manually check one of the more complicated types
        Expected <= 32'h0000_02B4; // Expected immediate value for the instruction (Bit 31, Bit 7, Bits 30-25, Bits 11-8, 0 with sign extension)
        @(posedge CLK);

        operate(10); // Simulate 10 random extensions for each of the 5 types of immediate

        repeat (5) @ (posedge CLK); // Allow some extra time at the end for visual clarity
        $stop; 
    end

    // Could just check sign extension amount and type.
    // Simulate the operation of the extender with random inputs
    task operate(int duration); begin
        for (int i = 0; i < 5; i++) begin
            Imm_Type_Sel = i; // Step through the 5 immediate types
            for (int j = 0; j < duration; j++) begin
                Instr = $urandom;
                case (Imm_Type_Sel)
                    IMM_I: Expected = {{21{Instr[31]}}, Instr[31:20]};
                    IMM_S: Expected = {{21{Instr[31]}}, Instr[31:25], Instr[11:7]};
                    IMM_B: Expected = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0};
                    IMM_U: Expected = {Instr[31:12], 12'b0};
                    IMM_J: Expected = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0};
                    default: Expected = 32'hX; // Default to X if no case is matched
                endcase
                @(posedge CLK);
            end
        end
	end
    endtask

    assertImmCorrect: assert property (@(posedge CLK) Imm_Ext === Expected)
            else $error("Error: Incorrect extension producted, expected %h, got %h", $sampled(Expected), $sampled(Imm_Ext));
    
endmodule