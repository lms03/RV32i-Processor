//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Branch Predcition Testbench                                                   
// Description: This is a testbench to ensure that the branch predictor and target buffer update their state and predict branches correctly
// Author: Luke Shepherd                                                     
// Date Modified: March 2025                                                                                                                                                                                                                                                        
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module branch_prediction_testbench;
    logic CLK; // Wrap module with a clock to control the sim more easily and better represent the external system
    logic RST;
    logic Branch_Taken_E, Predict_Taken_E, Predict_Out, Valid_F, Valid_E;
    logic [31:0] PC_Target_E, PC_F, PC_E, PC_Prediction;

    branch_predictor bp (
        .CLK(CLK),
        .RST(RST),
        .Branch_Taken(Branch_Taken_E),
        .Predict_Taken(Predict_Taken_E),
        .Valid(Valid_E),
        .Predict_Out(Predict_Out)
    );

    branch_target_buffer btb (
        .CLK(CLK),
        .RST(RST),
        .PC_F(PC_F),
        .PC_Target(PC_Target_E),
        .PC_E(PC_E),
        .Branch_Taken(Branch_Taken_E),
        .Valid(Valid_F),
        .PC_Prediction(PC_Prediction)
    );

    initial CLK <= 0; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        RST <= 1; // Initialize with reset
        @(posedge CLK); 
        RST <= 0; 
        Valid_E <= 0; // Initialize the valid bit
        @(posedge CLK); 

        // Test initial state
        assert(bp.current_state == WEAKLY_TAKEN && Predict_Out == 1) else $error("Error: Incorrect initial state, expected weakly taken (10) and predict bit 1, got %b and %b", $sampled(bp.current_state), $sampled(Predict_Out));
        assert(Valid_F == 0) else $error("Error: Incorrect validity, expected valid bit to be 0, got %b", $sampled(Valid_F));

        // Test unknown branch in BTB
        PC_F <= 32'h0;
        PC_E <= 32'h0; // Won't be written to BTB until after the assertion so branch is unknown
        PC_Target_E <= 32'h4;
        Branch_Taken_E <= 1;
        @(posedge CLK);
        assert(Valid_F == 0 && PC_Prediction == 32'h0) else $error("Error: Incorrect output, expected valid bit to be 0 and prediction to be 0x00000000 for unknown PC, got %b and %h", $sampled(Valid_F), $sampled(PC_Prediction));
        
        // Test known branch in BTB
        PC_F <= 32'hF;
        @(posedge CLK);
        PC_F <= 32'h0; // Set it to the known branch PC
        @(posedge CLK);
        assert(Valid_F == 1 && PC_Prediction == 32'h4) else $error("Error: Incorrect output, expected valid bit to be 1 and prediction to be 0x00000004 for known PC, got %b and %h", $sampled(Valid_F), $sampled(PC_Prediction));
        
        // Test predictor state increment
        Predict_Taken_E <= 1;
        Branch_Taken_E <= 1;
        Valid_E <= 1;
        @(posedge CLK);
        Valid_E <= 0;
        @(posedge CLK); // Ensure state transition 
        assert(bp.current_state == STRONGLY_TAKEN && Predict_Out == 1) else $error("Error: Incorrect state, expected strongly taken (11) and predict bit 1, got %b and %b", $sampled(bp.current_state), $sampled(Predict_Out));

        // Test predictor state increment again in edge state
        Predict_Taken_E <= 1;
        Branch_Taken_E <= 1;
        Valid_E <= 1;
        @(posedge CLK);
        Valid_E <= 0;
        @(posedge CLK); // Ensure state transition 
        assert(bp.current_state == STRONGLY_TAKEN && Predict_Out == 1) else $error("Error: Incorrect state, expected strongly taken (11) and predict bit 1, got %b and %b", $sampled(bp.current_state), $sampled(Predict_Out));


        // Test predictor state decrement
        Predict_Taken_E <= 0;
        Branch_Taken_E <= 1;
        Valid_E <= 1;
        @(posedge CLK);
        Valid_E <= 0;
        @(posedge CLK);
        assert(bp.current_state == WEAKLY_TAKEN && Predict_Out == 1) else $error("Error: Incorrect state, expected weakly taken (10) and predict bit 1, got %b and %b", $sampled(bp.current_state), $sampled(Predict_Out));

        // Test predictor state decrement to weakly untaken
        Predict_Taken_E <= 1;
        Branch_Taken_E <= 0;
        Valid_E <= 1;
        @(posedge CLK);
        Valid_E <= 0;
        @(posedge CLK);
        assert(bp.current_state == WEAKLY_UNTAKEN && Predict_Out == 0) else $error("Error: Incorrect state, expected weakly untaken (01) and predict bit 0, got %b and %b", $sampled(bp.current_state), $sampled(Predict_Out));

        // Test predictor state decrement to strongly untaken
        Predict_Taken_E <= 0;
        Branch_Taken_E <= 1;
        Valid_E <= 1;
        @(posedge CLK);
        Valid_E <= 0;
        @(posedge CLK);
        assert(bp.current_state == STRONGLY_UNTAKEN && Predict_Out == 0) else $error("Error: Incorrect state, expected strongly untaken (00) and predict bit 0, got %b and %b", $sampled(bp.current_state), $sampled(Predict_Out));

        // Test predictor state decrement again in edge state
        Predict_Taken_E <= 1;
        Branch_Taken_E <= 0;
        Valid_E <= 1;
        @(posedge CLK);
        Valid_E <= 0;
        @(posedge CLK);
        assert(bp.current_state == STRONGLY_UNTAKEN && Predict_Out == 0) else $error("Error: Incorrect state, expected strongly untaken (00) and predict bit 0, got %b and %b", $sampled(bp.current_state), $sampled(Predict_Out));

        
        repeat (5) @ (posedge CLK); // Allow some extra time at the end for visual clarity
        $stop; 
    end
endmodule