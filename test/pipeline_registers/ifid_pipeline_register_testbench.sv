//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Fetch to Decode Pipeline Register Testbench                                                  
// Description: Tests that the pipeline register responds to control signals correctly and passes data through.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                            
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module ifid_pipeline_register_testbench ();
    // Global control signals
    logic CLK, RST, Flush_D, Stall_En;
    
    // Input signals
    logic [31:0] PC_F, PC_Plus_4_F;
    logic Predict_Taken_F;

    // Output signals
    logic [31:0] PC_D, PC_Plus_4_D;
    logic Predict_Taken_D;

    ifid_register ifid (
        .CLK(CLK),
        .RST(RST),
        .Flush_D(Flush_D),
        .Stall_En(Stall_En),
        .PC_F(PC_F),
        .PC_Plus_4_F(PC_Plus_4_F),
        .Predict_Taken_F(Predict_Taken_F),
        .PC_D(PC_D),
        .PC_Plus_4_D(PC_Plus_4_D),
        .Predict_Taken_D(Predict_Taken_D)
    );

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        // Reset and initialize signals
        RST <= 1;
        Flush_D <= 0;
        Stall_En <= 0;
        @(posedge CLK);
        RST <= 0;

        // Test reset
        operate(5);
        RST <= 1;
        @(posedge CLK);
        RST <= 0;

        // Test stall
        operate(5);
        Stall_En <= 1;
        @(posedge CLK);
        Stall_En <= 0;

        // Test flush
        operate(5);
        Flush_D <= 1;
        @(posedge CLK);
        Flush_D <= 0;

        // Test normal operation and then end
        operate(5);
        $stop;
    end

    task operate(int duration); begin
        for (int i = 0; i < duration; i++) begin
            PC_F <= $urandom;
            PC_Plus_4_F <= $urandom;
            Predict_Taken_F <= $urandom;
            @(posedge CLK);
        end
    end
    endtask

    // Assert register resets instruction to 0x00000000 to prevent state changes
    assertRegisterReset: assert property (@(posedge CLK) (RST |-> ##1 (Predict_Taken_D == 1'b0)) )
        else $error("Error: Register did not reset correctly, expected Predict_Taken_D 0x0 but got Predict_Taken_D %h", $sampled(Predict_Taken_D));

    // Assert register keeps the same value when stall is asserted
    assertRegisterStall: assert property (@(posedge CLK) ((Stall_En && !Flush_D && !RST) |-> ##1 (PC_D == $past(PC_D) && PC_Plus_4_D == $past(PC_Plus_4_D) && Predict_Taken_D == $past(Predict_Taken_D)))) 
        else $error("Error: Register did not stall correctly, expected PC %h, PC+4 %h, Predict %h but got PC %h, PC+4 %h, Predict %h", $sampled($past(PC_D)), $sampled($past(PC_Plus_4_D)), $sampled($past(Predict_Taken_D)), $sampled(PC_D), $sampled(PC_Plus_4_D), $sampled(Predict_Taken_D));

    // Assert register inserts a NOP when flush is asserted
    assertRegisterFlush: assert property (@(posedge CLK) ((Flush_D && !RST) |-> ##1 (Predict_Taken_D == 1'b0 && PC_D == 32'h2A2A_2A2A && PC_Plus_4_D == 32'h2A2A_2A2A))) 
        else $error("Error: Register did not flush correctly, expected Predict_Taken_D 0x0, PC 0x2A2A_2A2A, PC+4 0x2A2A_2A2A but got Predict_Taken_D %h, PC %h, PC+4 %h", $sampled(Predict_Taken_D), $sampled(PC_D), $sampled(PC_Plus_4_D));

    // Assert register passes data through when supposed to (control signals low)
    assertRegisterNormal: assert property (@(posedge CLK) ((!Stall_En && !Flush_D && !RST) |-> ##1 (PC_D == $past(PC_F) && PC_Plus_4_D == $past(PC_Plus_4_F) && Predict_Taken_D == $past(Predict_Taken_F)))) 
        else $error("Error: Register did not pass data correctly, expected PC %h, PC+4 %h, Predict %h but got PC %h, PC+4 %h, Predict %h", $sampled($past(PC_F)), $sampled($past(PC_Plus_4_F)), $sampled($past(Predict_Taken_F)), $sampled(PC_D), $sampled(PC_Plus_4_D), $sampled(Predict_Taken_D));

endmodule