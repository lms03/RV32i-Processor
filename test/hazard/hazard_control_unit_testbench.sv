//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Hazard Control Unit Testbench                                                
// Description: Ensures that the hazard control unit produces the correct control signals for pipeline inputs.
// Author: Luke Shepherd                                                     
// Date Modified: March 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module hazard_control_unit_testbench;
    logic CLK; // Wrap module with a clock to better represent the outside system

    // Input signals
    logic [4:0] RS1_D, RS2_D, RD_E;
    logic [1:0] Result_Src_Sel_E;
    logic [4:0] RS1_E, RS2_E, RD_M, RD_W;
    logic REG_W_En_M, REG_W_En_W;
    logic Branch_Taken_E, Predict_Taken_E;

    // Output signals
    logic [1:0] FWD_SrcA, FWD_SrcB;
    logic Stall_En, Flush_D, Flush_E, PC_En;

    hazard_control_unit hcu (
        .RS1_D(RS1_D), 
        .RS2_D(RS2_D), 
        .RD_E(RD_E),
        .Result_Src_Sel_E(Result_Src_Sel_E),
        .RS1_E(RS1_E), 
        .RS2_E(RS2_E), 
        .RD_M(RD_M), 
        .RD_W(RD_W),
        .REG_W_En_M(REG_W_En_M), 
        .REG_W_En_W(REG_W_En_W),
        .Branch_Taken_E(Branch_Taken_E), 
        .Predict_Taken_E(Predict_Taken_E),
        .FWD_SrcA(FWD_SrcA), 
        .FWD_SrcB(FWD_SrcB),
        .Stall_En(Stall_En), 
        .Flush_D(Flush_D), 
        .Flush_E(Flush_E), 
        .PC_En(PC_En)
    );

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        // Initialize signals
        RS1_D <= 5'b0;
        RS2_D <= 5'b0;
        RD_E <= 5'b0;
        Result_Src_Sel_E <= 2'h0;
        RS1_E <= 5'b0;
        RS2_E <= 5'b0;
        RD_M <= 5'b0;
        RD_W <= 5'b0;
        REG_W_En_M <= 1'b0;
        REG_W_En_W <= 1'b0;
        Branch_Taken_E <= 1'b0;
        Predict_Taken_E <= 1'b0;
        @(posedge CLK);

        // Test regular operation 
        RS1_D <= 5'b00000;  // x0
        RS2_D <= 5'b00001;  // x1
        RD_E <= 5'b11111;   // x31, no clash with rs1/rs2_D
        Result_Src_Sel_E <= RESULT_ALU; // Not load
        RS1_E <= 5'b00000;  // x0
        RS2_E <= 5'b00001;  // x1
        RD_M <= 5'b00011;   // x3, no clashes with rs1/rs2_E
        RD_W <= 5'b00010;   // x2, no clashes with rs1/rs2_E
        REG_W_En_M <= 1'b0;
        REG_W_En_W <= 1'b0;
        Branch_Taken_E <= 1'b0; // Ensure branch and predict taken are the same
        Predict_Taken_E <= 1'b0;
        @(posedge CLK);
        check_signals(FWD_NONE, FWD_NONE, 0, 0, 0, 1);

        // Test regular operation with partial condition passing
        RS1_D <= 5'b00011;  // x3
        RS2_D <= 5'b00001;  // x1
        RD_E <= 5'b11111;   // x31, no clash with rs1/rs2_D
        Result_Src_Sel_E <= RESULT_MEM; // Load but no dependency so shouldn't pass
        RS1_E <= 5'b00011;  // x3
        RS2_E <= 5'b00001;  // x1
        RD_M <= 5'b00100;   // x4, no clashes with rs1/rs2_E
        RD_W <= 5'b00010;   // x2, no clashes with rs1/rs2_E
        REG_W_En_M <= 1'b1; // Write but no dependency so shouldn't pass
        REG_W_En_W <= 1'b1;
        Branch_Taken_E <= 1'b0; // Ensure branch and predict taken are the same
        Predict_Taken_E <= 1'b0;
        @(posedge CLK);
        check_signals(FWD_NONE, FWD_NONE, 0, 0, 0, 1);

        // Test regular operation with partial condition passing
        RS1_D <= 5'b00011;  // x3
        RS2_D <= 5'b00001;  // x1
        RD_E <= 5'b00001;   // x1, clash with rs2_D
        Result_Src_Sel_E <= RESULT_ALU; // Not a load so should prevent stall
        RS1_E <= 5'b00011;  // x3
        RS2_E <= 5'b00001;  // x1
        RD_M <= 5'b00011;   // x3, clashes with rs1_E
        RD_W <= 5'b00001;   // x1, clashes with rs2_E
        REG_W_En_M <= 1'b0; // No write so shouldn't pass
        REG_W_En_W <= 1'b0;
        Branch_Taken_E <= 1'b0; // Ensure branch and predict taken are the same
        Predict_Taken_E <= 1'b0;
        @(posedge CLK);
        check_signals(FWD_NONE, FWD_NONE, 0, 0, 0, 1);

        // Test SrcA memory forwarding
        RS1_D <= 5'b00000;  // N/A
        RS2_D <= 5'b00000;  // N/A
        RD_E <= 5'b11111;   // N/A
        Result_Src_Sel_E <= 2'h0; // N/A
        RS1_E <= 5'b00001;  // x1
        RS2_E <= 5'b00011;  // x3
        RD_M <= 5'b00001;   // x1, clashes with rs1_E
        RD_W <= 5'b11111;   // x31, no clashes with rs1/rs2_E
        REG_W_En_M <= 1'b1; // Write to cause dependency between execute and memory instructions
        REG_W_En_W <= 1'b0; // N/A
        Branch_Taken_E <= 1'b0; // Ensure no branch misprediction
        Predict_Taken_E <= 1'b0;
        @(posedge CLK);
        check_signals(FWD_MEM, FWD_NONE, 0, 0, 0, 1);

        // Test SrcA writeback forwarding
        RS1_D <= 5'b00000;  // N/A
        RS2_D <= 5'b00000;  // N/A
        RD_E <= 5'b11111;   // N/A
        Result_Src_Sel_E <= 2'h0; // N/A
        RS1_E <= 5'b00001;  // x1
        RS2_E <= 5'b00011;  // x3
        RD_M <= 5'b11111;   // x31, no clashes with rs1/rs2_E 
        RD_W <= 5'b00001;   // x1, clashes with rs1_E
        REG_W_En_M <= 1'b0; // N/A 
        REG_W_En_W <= 1'b1; // Write to cause dependency between execute and memory instructions
        Branch_Taken_E <= 1'b0; // Ensure no branch misprediction
        Predict_Taken_E <= 1'b0;
        @(posedge CLK);
        check_signals(FWD_WB, FWD_NONE, 0, 0, 0, 1);

        // Test SrcB memory forwarding
        RS1_D <= 5'b00000;  // N/A
        RS2_D <= 5'b00000;  // N/A
        RD_E <= 5'b11111;   // N/A
        Result_Src_Sel_E <= 2'h0; // N/A
        RS1_E <= 5'b00011;  // x3
        RS2_E <= 5'b00001;  // x1
        RD_M <= 5'b00001;   // x1, clashes with rs2_E
        RD_W <= 5'b11111;   // x31, no clashes with rs1/rs2_E
        REG_W_En_M <= 1'b1; // Write to cause dependency between execute and memory instructions
        REG_W_En_W <= 1'b0; // N/A
        Branch_Taken_E <= 1'b0; // Ensure no branch misprediction
        Predict_Taken_E <= 1'b0;
        @(posedge CLK);
        check_signals(FWD_NONE, FWD_MEM, 0, 0, 0, 1);

        // Test SrcB writeback forwarding
        RS1_D <= 5'b00000;  // N/A
        RS2_D <= 5'b00000;  // N/A
        RD_E <= 5'b11111;   // N/A
        Result_Src_Sel_E <= 2'h0; // N/A
        RS1_E <= 5'b00001;  // x1
        RS2_E <= 5'b00011;  // x3
        RD_M <= 5'b11111;   // x31, no clashes with rs1/rs2_E 
        RD_W <= 5'b00011;   // x3, clashes with rs2_E
        REG_W_En_M <= 1'b0; // N/A 
        REG_W_En_W <= 1'b1; // Write to cause dependency between execute and memory instructions
        Branch_Taken_E <= 1'b0; // Ensure no branch misprediction
        Predict_Taken_E <= 1'b0;
        @(posedge CLK);
        check_signals(FWD_NONE, FWD_WB, 0, 0, 0, 1);

        // Test branch misprediction untaken
        RS1_D <= 5'b00000;  // N/A
        RS2_D <= 5'b00000;  // N/A
        RD_E <= 5'b11111;   // N/A
        Result_Src_Sel_E <= 2'h0; // N/A
        RS1_E <= 5'b00000;  // N/A
        RS2_E <= 5'b00000;  // N/A
        RD_M <= 5'b11111;   // N/A
        RD_W <= 5'b11111;   // N/A
        REG_W_En_M <= 1'b0; // N/A 
        REG_W_En_W <= 1'b0; // N/A
        Branch_Taken_E <= 1'b1; // Mispredict untaken
        Predict_Taken_E <= 1'b0;
        @(posedge CLK);
        check_signals(FWD_NONE, FWD_NONE, 0, 1, 1, 1); // Should flush both stages
        
        // Test branch misprediction taken
        RS1_D <= 5'b00000;  // N/A
        RS2_D <= 5'b00000;  // N/A
        RD_E <= 5'b11111;   // N/A
        Result_Src_Sel_E <= 2'h0; // N/A
        RS1_E <= 5'b00000;  // N/A
        RS2_E <= 5'b00000;  // N/A
        RD_M <= 5'b11111;   // N/A
        RD_W <= 5'b11111;   // N/A
        REG_W_En_M <= 1'b0; // N/A 
        REG_W_En_W <= 1'b0; // N/A
        Branch_Taken_E <= 1'b0; // Mispredict taken
        Predict_Taken_E <= 1'b1;
        @(posedge CLK);
        check_signals(FWD_NONE, FWD_NONE, 0, 1, 1, 1); // Should flush both stages
        
        // Test load RAW hazard (Insert bubble Stall+Flush)
        RS1_D <= 5'b00011;  // x3
        RS2_D <= 5'b00001;  // x1
        RD_E <= 5'b00001;   // x1, clashes with rs2_D
        Result_Src_Sel_E <= RESULT_MEM; // Load
        RS1_E <= 5'b00000;  // N/A
        RS2_E <= 5'b00000;  // N/A
        RD_M <= 5'b11111;   // N/A
        RD_W <= 5'b11111;   // N/A
        REG_W_En_M <= 1'b0; // N/A 
        REG_W_En_W <= 1'b0; // N/A
        Branch_Taken_E <= 1'b0; // Ensure no branch misprediction
        Predict_Taken_E <= 1'b0;
        @(posedge CLK);
        check_signals(FWD_NONE, FWD_NONE, 1, 0, 1, 0); // Should flush idex and stall ifid to insert a bubble
        $stop; 
    end

    task check_signals(
        input logic [1:0] expected_FWD_SrcA,
        input logic [1:0] expected_FWD_SrcB,
        input logic expected_Stall_En,
        input logic expected_Flush_D,
        input logic expected_Flush_E,
        input logic expected_PC_En
    );
    begin
        assert (FWD_SrcA == expected_FWD_SrcA) else $error("Error: Incorrect FWD_SrcA produced, expected %h, got %h", expected_FWD_SrcA, $sampled(FWD_SrcA));
        assert (FWD_SrcB == expected_FWD_SrcB) else $error("Error: Incorrect FWD_SrcB produced, expected %h, got %h", expected_FWD_SrcB, $sampled(FWD_SrcB));
        assert (Stall_En == expected_Stall_En) else $error("Error: Incorrect Stall_En produced, expected %h, got %h", expected_Stall_En, $sampled(Stall_En));
        assert (Flush_D == expected_Flush_D) else $error("Error: Incorrect Flush_D produced, expected %h, got %h", expected_Flush_D, $sampled(Flush_D));
        assert (Flush_E == expected_Flush_E) else $error("Error: Incorrect Flush_E produced, expected %h, got %h", expected_Flush_E, $sampled(Flush_E));
        assert (PC_En == expected_PC_En) else $error("Error: Incorrect PC_En produced, expected %h, got %h", expected_PC_En, $sampled(PC_En));
    end
    endtask
endmodule