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
        assert (Result == 32'h0000_0002) else $error("Error: Incorrect result produced for basic ADD test, expected 0x00000002, got 0x0x%h", $sampled(Result));

        // Check the ALU handles overflows correctly (overflow is ignored)
        ALU_Control <= ALU_ADD;
        SrcA <= 32'h0000_0001;
        SrcB <= 32'h7FFF_FFFF; // Signed arithmetic maximum positive value (2^31 - 1)
        @(posedge CLK);
        assert (Result == 32'h8000_0000) else $error("Error: Incorrect result produced for overflow ADD test, expected 0x80000000, got 0x0x%h", $sampled(Result));

        // Check that the ALU handles signed arithmetic correctly
        ALU_Control <= ALU_ADD;
        SrcA <= 32'hFFFF_FFFF; // Signed arithmetic minimum negative value (-1)
        SrcB <= 32'hFFFF_FFFF; 
        @(posedge CLK);
        assert (Result == 32'hFFFF_FFFE) else $error("Error: Incorrect result produced for signed ADD test, expected 0x00000000, got 0x0x%h", $sampled(Result));

        // Test basic subtraction
        ALU_Control <= ALU_SUB;
        SrcA <= 32'h0000_0001;
        SrcB <= 32'h0000_0001;
        @(posedge CLK);
        assert (Result == 32'h0000_0000) else $error("Error: Incorrect result produced for basic SUB test, expected 0x00000000, got 0x0x%h", $sampled(Result));

        // Check that the ALU handles negative overflow correctly
        ALU_Control <= ALU_SUB;
        SrcA <= 32'h8000_0000;
        SrcB <= 32'h0000_0001;
        @(posedge CLK);
        assert (Result == 32'h7FFF_FFFF) else $error("Error: Incorrect result produced for overflow SUB test, expected 0x7FFFFFFF, got 0x0x%h", $sampled(Result));

        // Test AND operation
        ALU_Control <= ALU_AND;
        SrcA <= 32'h0000_0000;
        SrcB <= 32'hFFFF_FFFF;
        @(posedge CLK);
        assert (Result == 32'h0000_0000) else $error("Error: Incorrect result produced for AND test, expected 0x00000000, got 0x0x%h", $sampled(Result));

        // Test AND operation with all bits set
        ALU_Control <= ALU_AND;
        SrcA <= 32'hFFFF_FFFF;
        SrcB <= 32'hFFFF_FFFF;
        @(posedge CLK);
        assert (Result == 32'hFFFF_FFFF) else $error("Error: Incorrect result produced for AND test, expected 0xFFFFFFFF, got 0x0x%h", $sampled(Result));

        // Test OR operation
        ALU_Control <= ALU_OR;
        SrcA <= 32'h0000_0000;
        SrcB <= 32'hFFFF_FFFF;
        @(posedge CLK);
        assert (Result == 32'hFFFF_FFFF) else $error("Error: Incorrect result produced for OR test, expected 0xFFFFFFFF, got 0x0x%h", $sampled(Result));

        // Test OR operation with all bits set
        ALU_Control <= ALU_OR;
        SrcA <= 32'hFFFF_FFFF;
        SrcB <= 32'hFFFF_FFFF;
        @(posedge CLK);
        assert (Result == 32'hFFFF_FFFF) else $error("Error: Incorrect result produced for OR test, expected 0xFFFFFFFF, got 0x0x%h", $sampled(Result));

        // Test OR operation with no bits set
        ALU_Control <= ALU_OR;
        SrcA <= 32'h0000_0000;
        SrcB <= 32'h0000_0000;
        @(posedge CLK);
        assert (Result == 32'h0000_0000) else $error("Error: Incorrect result produced for OR test, expected 0x00000000, got 0x0x%h", $sampled(Result));

        // Test XOR operation
        ALU_Control <= ALU_XOR;
        SrcA <= 32'h0000_0000;
        SrcB <= 32'hFFFF_FFFF;
        @(posedge CLK);
        assert (Result == 32'hFFFF_FFFF) else $error("Error: Incorrect result produced for XOR test, expected 0xFFFFFFFF, got 0x0x%h", $sampled(Result));

        // Test XOR operation with all bits set
        ALU_Control <= ALU_XOR;
        SrcA <= 32'hFFFF_FFFF;
        SrcB <= 32'hFFFF_FFFF;
        @(posedge CLK);
        assert (Result == 32'h0000_0000) else $error("Error: Incorrect result produced for XOR test, expected 0x00000000, got 0x0x%h", $sampled(Result));

        // Test XOR operation with no bits set
        ALU_Control <= ALU_XOR;
        SrcA <= 32'h0000_0000;
        SrcB <= 32'h0000_0000;
        @(posedge CLK);
        assert (Result == 32'h0000_0000) else $error("Error: Incorrect result produced for XOR test, expected 0x00000000, got 0x0x%h", $sampled(Result));

        // Test SLL operation
        ALU_Control <= ALU_SLL;
        SrcA <= 32'hF0F0_F0F0;
        SrcB <= 32'h0000_0004;
        @(posedge CLK);
        assert (Result == 32'h0F0F_0F00) else $error("Error: Incorrect result produced for SLL test, expected 0x0F0F0F00, got 0x0x%h", $sampled(Result));

        // Check SLL operation multiplies
        ALU_Control <= ALU_SLL;
        SrcA <= 32'h0000_0001;
        SrcB <= 32'h0000_0002; // 2^2 = 4
        @(posedge CLK);
        assert (Result == 32'h0000_0004) else $error("Error: Incorrect result produced for SLL multiply test, expected 0x00000004, got 0x0x%h", $sampled(Result));

        // Test SRL operation
        ALU_Control <= ALU_SRL;
        SrcA <= 32'hF0F0_F0F0;
        SrcB <= 32'h0000_0004;
        @(posedge CLK);
        assert (Result == 32'h0F0F_0F0F) else $error("Error: Incorrect result produced for SRL test, expected 0x0F0F0F0F, got 0x0x%h", $sampled(Result));

        // Check SRL operation divides
        ALU_Control <= ALU_SRL;
        SrcA <= 32'h0000_0010; 
        SrcB <= 32'h0000_0001; // 2^1 = 2
        @(posedge CLK);
        assert (Result == 32'h0000_0008) else $error("Error: Incorrect result produced for SRL divide test, expected 0x00000008, got 0x0x%h", $sampled(Result));

        // Test SLL followed by SRL is the same
        ALU_Control <= ALU_SLL;
        SrcA <= 32'h0000_0001;
        SrcB <= 32'h0000_0001;
        @(posedge CLK);
        ALU_Control <= ALU_SRL;
        SrcA <= Result;
        SrcB <= 32'h0000_0001;
        @(posedge CLK);
        assert (Result == 32'h0000_0001) else $error("Error: Incorrect result produced for SLL/SRL test, expected 0x00000001, got 0x0x%h", $sampled(Result));

        // Test SRA operation
        ALU_Control <= ALU_SRA;
        SrcA <= 32'hFFFF_FFFF;
        SrcB <= 32'h7FFF_FFFF;
        @(posedge CLK);
        assert (Result == 32'hFFFF_FFFF) else $error("Error: Incorrect result produced for SRA test, expected 0xFFFFFFFF, got 0x0x%h", $sampled(Result));

        // Test passing BEQ
        ALU_Control <= ALU_BEQ;
        SrcA <= 32'hFFFF_FFFF;
        SrcB <= 32'hFFFF_FFFF;
        @(posedge CLK);
        assert (Branch_Condition == 1'b1) else $error("Error: Incorrect result produced for passing BEQ test, expected 1, got 0x0x%h", $sampled(Branch_Condition));

        // Test failing BEQ
        ALU_Control <= ALU_BEQ;
        SrcA <= 32'hFFFF_FFFF;
        SrcB <= 32'h0000_0000;
        @(posedge CLK);
        assert (Branch_Condition == 1'b0) else $error("Error: Incorrect result produced for failing BEQ test, expected 0, got 0x0x%h", $sampled(Branch_Condition));

        // Test passing BNE
        ALU_Control <= ALU_BNE;
        SrcA <= 32'hFFFF_FFFF;
        SrcB <= 32'h0000_0000;
        @(posedge CLK);
        assert (Branch_Condition == 1'b1) else $error("Error: Incorrect result produced for passing BNE test, expected 1, got 0x0x%h", $sampled(Branch_Condition));

        // Test failing BNE
        ALU_Control <= ALU_BNE;
        SrcA <= 32'hFFFF_FFFF;
        SrcB <= 32'hFFFF_FFFF;
        @(posedge CLK);
        assert (Branch_Condition == 1'b0) else $error("Error: Incorrect result produced for failing BNE test, expected 0, got 0x0x%h", $sampled(Branch_Condition));

        // Test passing BLT
        ALU_Control <= ALU_BLT;
        SrcA <= 32'hFFFF_FFFF;
        SrcB <= 32'h0000_0000;
        @(posedge CLK);
        assert (Branch_Condition == 1'b1 && Result == 32'h0000_0001) else $error("Error: Incorrect result produced for passing BLT test, expected taken 1, got 0x0x%h, result (SLT) 0x00000001, got 0x0x%h", $sampled(Branch_Condition), $sampled(Result));

        // Test failing BLT
        ALU_Control <= ALU_BLT;
        SrcA <= 32'h0000_0000;
        SrcB <= 32'h0000_0000;
        @(posedge CLK);
        assert (Branch_Condition == 1'b0 && Result == 32'h0000_0000) else $error("Error: Incorrect result produced for failing BLT test, expected taken 0, got 0x0x%h, result (SLT) 0x00000000, got 0x0x%h", $sampled(Branch_Condition), $sampled(Result));

        // Test passing BLTU
        ALU_Control <= ALU_BLTU;
        SrcA <= 32'h0000_0000;
        SrcB <= 32'hFFFF_FFFF;
        @(posedge CLK);
        assert (Branch_Condition == 1'b1 && Result == 32'h0000_0001) else $error("Error: Incorrect result produced for passing BLTU test, expected taken 1, got 0x0x%h, result (SLTU) 0x00000001, got 0x0x%h", $sampled(Branch_Condition), $sampled(Result));

        // Test failing BLTU
        ALU_Control <= ALU_BLTU;
        SrcA <= 32'hFFFF_FFFF;
        SrcB <= 32'h0000_0000;
        @(posedge CLK);
        assert (Branch_Condition == 1'b0 && Result == 32'h0000_0000) else $error("Error: Incorrect result produced for failing BLTU test, expected taken 0, got 0x0x%h, result (SLTU) 0x00000000, got 0x0x%h", $sampled(Branch_Condition), $sampled(Result));

        // Test passing BGE
        ALU_Control <= ALU_BGE;
        SrcA <= 32'h0000_0000;
        SrcB <= 32'hFFFF_FFFF;
        @(posedge CLK);
        assert (Branch_Condition == 1'b1) else $error("Error: Incorrect result produced for passing BGE test, expected 1, got 0x%h", $sampled(Branch_Condition));

        // Test failing BGE
        ALU_Control <= ALU_BGE;
        SrcA <= 32'h0000_0000;
        SrcB <= 32'h0000_0001;
        @(posedge CLK);
        assert (Branch_Condition == 1'b0) else $error("Error: Incorrect result produced for failing BGE test, expected 0, got 0x%h", $sampled(Branch_Condition));

        // Test passing BGEU
        ALU_Control <= ALU_BGEU;
        SrcA <= 32'hFFFF_FFFF;
        SrcB <= 32'h0000_0000;
        @(posedge CLK);
        assert (Branch_Condition == 1'b1) else $error("Error: Incorrect result produced for passing BGEU test, expected 1, got 0x%h", $sampled(Branch_Condition));

        // Test failing BGEU
        ALU_Control <= ALU_BGEU;
        SrcA <= 32'h0000_0000;
        SrcB <= 32'hFFFF_FFFF;
        @(posedge CLK);
        assert (Branch_Condition == 1'b0) else $error("Error: Incorrect result produced for failing BGEU test, expected 0, got 0x%h", $sampled(Branch_Condition));

        // Test LUI takes SrcB value
        ALU_Control <= ALU_LUI;
        SrcA <= 32'h0000_0000;
        SrcB <= 32'hFFFF_FFFF;
        @(posedge CLK);
        assert (Result == 32'hFFFF_FFFF) else $error("Error: Incorrect result produced for LUI test, expected 0xFFFFFFFF, got 0x%h", $sampled(Branch_Condition));

        // Test LUI takes different SrcB value
        ALU_Control <= ALU_LUI;
        SrcA <= 32'h0000_0000;
        SrcB <= 32'hF0F0_F0F0;
        @(posedge CLK);
        assert (Result == 32'hF0F0_F0F0) else $error("Error: Incorrect result produced for LUI test, expected 0xF0F0F0F0, got 0x%h", $sampled(Branch_Condition));
        $stop; 
    end
endmodule