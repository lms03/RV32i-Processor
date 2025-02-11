//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Arithmetic Logic Unit Testbench                                                   
// Description: This is a testbench to ensure that the ALU performs the correct operations. 
// Author: Luke Shepherd                                                     
// Date Created: February 2025                                                                                                                                                                                                                                                      
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module arithmetic_logic_unit_testbench;
    logic CLK; // Wrap module with a clock to better represent the outside system

    // Input signals
    logic [3:0] ALU_Control;
    logic [31:0] SrcA, SrcB;

    // Output signals
    logic [31:0] Result;
    logic Branch_Condition;

    arithmetic_logic_unit alu (
        .ALU_Control(ALU_Control),
        .SrcA(SrcA),
        .SrcB(SrcB),
        .Result(Result),
        .Branch_Condition(Branch_Condition)
    );

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        // Initialize signals
        ALU_Control <= ALU_ADD;
        SrcA <= 32'h0;
        SrcB <= 32'h0;
        @(posedge CLK);

        // Test basic addition
        ALU_Control <= ALU_ADD;
        SrcA <= 32'h0000_0001;
        SrcB <= 32'h0000_0001;
        @(posedge CLK);
        assert (Result == 32'h0000_0002) else $error("Error: Incorrect result produced for basic ADD test, expected 0x00000002, got %h", $sampled(Result));

        // Check the ALU handles overflows correctly (overflow is ignored)
        ALU_Control <= ALU_ADD;
        SrcA <= 32'h0000_0001;
        SrcB <= 32'h7FFF_FFFF; // Signed arithmetic maximum positive value (2^31 - 1)
        @(posedge CLK);
        assert (Result == 32'h8000_0000) else $error("Error: Incorrect result produced for overflow ADD test, expected 0x80000000, got %h", $sampled(Result));

        // Check that the ALU handles signed arithmetic correctly
        ALU_Control <= ALU_ADD;
        SrcA <= 32'hFFFF_FFFF; // Signed arithmetic minimum negative value (-1)
        SrcB <= 32'hFFFF_FFFF; 
        @(posedge CLK);
        assert (Result == 32'hFFFF_FFFE) else $error("Error: Incorrect result produced for signed ADD test, expected 0x00000000, got %h", $sampled(Result));

        // Test basic subtraction
        ALU_Control <= ALU_SUB;
        SrcA <= 32'h0000_0001;
        SrcB <= 32'h0000_0001;
        @(posedge CLK);
        assert (Result == 32'h0000_0000) else $error("Error: Incorrect result produced for basic SUB test, expected 0x00000000, got %h", $sampled(Result));

        // Check that the ALU handles negative overflow correctly
        ALU_Control <= ALU_SUB;
        SrcA <= 32'h8000_0000;
        SrcB <= 32'h0000_0001;
        @(posedge CLK);
        assert (Result == 32'h7FFF_FFFF) else $error("Error: Incorrect result produced for overflow SUB test, expected 0x7FFFFFFF, got %h", $sampled(Result));

        // Test ALU_AND

        // Test ALU_OR

        // Test ALU_XOR

        // Test ALU_SLL

        // Test ALU_SRL

        // Test ALU_SRA

        // Test ALU_BEQ

        // Test ALU_BNE

        // Test ALU_BLT

        // Test ALU_BLTU
        
        // Test ALU_BGE

        // Test ALU_BGEU

        // Test ALU_LUI

        // Test 
        $stop; 
    end


endmodule