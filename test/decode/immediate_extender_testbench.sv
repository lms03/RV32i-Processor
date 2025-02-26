//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Immediate Extender Testbench                                                   
// Description: This is a testbench to ensure that the immediate extender appropriately extends immediate values based on the instruction type.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                                        
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

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        @(posedge CLK); // Wait for first posedge before starting

        Instr <= 32'h2A2A_2A2A; // Initialize instruction for first manual check
        Imm_Type_Sel <= IMM_I; // Initialize type to I-type
        @(posedge CLK);
        assert (Imm_Ext == 32'h0000_02A2) else $error("Error: Incorrect extension produced, expected 0x000002A2, got %h", $sampled(Imm_Ext));

        Imm_Type_Sel <= IMM_S;
        @(posedge CLK);
        assert (Imm_Ext == 32'h0000_02B4) else $error("Error: Incorrect extension produced, expected 0x000002B4, got %h", $sampled(Imm_Ext));

        Imm_Type_Sel <= IMM_B;
        @(posedge CLK);
        assert (Imm_Ext == 32'h0000_02B4) else $error("Error: Incorrect extension produced, expected 0x000002B4, got %h", $sampled(Imm_Ext));

        Imm_Type_Sel <= IMM_U;
        @(posedge CLK);
        assert (Imm_Ext == 32'h2A2A_2000) else $error("Error: Incorrect extension produced, expected 0x2A2A2000, got %h", $sampled(Imm_Ext));

        Imm_Type_Sel <= IMM_J;
        @(posedge CLK);
        assert (Imm_Ext == 32'h000A_22A2) else $error("Error: Incorrect extension produced, expected 0x000A22A2, got %h", $sampled(Imm_Ext));

        operate(10); // Simulate 10 random extensions for each of the 5 types of immediate

        repeat (5) @ (posedge CLK); // Allow some extra time at the end for visual clarity
        $stop; 
    end

    // Simulate the operation of the extender with random inputs
    task operate(int duration); begin
        for (int i = 0; i < 5; i++) begin
            Imm_Type_Sel = i; // Step through the 5 immediate types
            for (int j = 0; j < duration; j++) begin
                Instr = $urandom;
                @(posedge CLK);
                assert (Imm_Ext[31] == Instr[31]) else $error("Error: Incorrect sign produced, expected %h, got %h", $sampled(Instr[31]), $sampled(Imm_Ext[31]));
                case(Imm_Type_Sel)
                    IMM_I, IMM_S, IMM_B: assert (Imm_Ext[31:12] == {20{Instr[31]}}) else $error("Error: Incorrect extension produced, expected %h, got %h", {20{Instr[31]}}, $sampled(Imm_Ext[31:12]));
                    IMM_U: assert (Imm_Ext[11:0] == 12'b0) else $error("Error: Incorrect extension produced, expected %h, got %h", 12'b0 ,$sampled(Imm_Ext[11:0]));
                    IMM_J: assert (Imm_Ext[31:20] == {12{Instr[31]}}) else $error("Error: Incorrect extension produced, expected %h, got %h", {12{Instr[31]}}, $sampled(Imm_Ext[31:20])); 
                    default: $error("Error: Test should not reach this, R-Type does not exist in immediate extender");
                endcase
                if(Imm_Type_Sel == IMM_J || Imm_Type_Sel == IMM_B) assert (Imm_Ext[0] == 0) else $error("Error: Incorrect extension produced, expected 0, got %h", $sampled(Imm_Ext[0]));
            end
        end
	end
    endtask
    
endmodule