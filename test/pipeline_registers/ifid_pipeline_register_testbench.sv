//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Fetch to Decode Pipeline Register Testbench                                                  
// Description: Tests that the pipeline register responds to control signals correctly and passes data through.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                            
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module ifid_pipeline_register_testbench ();
    logic CLK;
    logic RST;
    logic Flush_D;
    logic Stall_En;
    logic [31:0] Instr_F;
    logic [31:0] PC_F;
    logic [31:0] PC_Plus_4_F;
    logic [31:0] Instr_D;
    logic [31:0] PC_D;
    logic [31:0] PC_Plus_4_D;

    ifid_register ifid (
        .CLK(CLK),
        .RST(RST),
        .Flush_D(Flush_D),
        .Stall_En(Stall_En),
        .Instr_F(Instr_F),
        .PC_F(PC_F),
        .PC_Plus_4_F(PC_Plus_4_F),
        .Instr_D(Instr_D),
        .PC_D(PC_D),
        .PC_Plus_4_D(PC_Plus_4_D)
    );

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        // Initialize signals with reset and flush
        RST <= 1;
        Stall_En <= 0;
        Flush_D <= 1;
        Instr_F <= 32'h0;
        PC_F <= 32'h0;
        PC_Plus_4_F <= 32'h0;
        @(posedge CLK);
        RST <= 0;
        Flush_D <= 0;

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
            Instr_F <= $urandom_range(0, 32'hFFFFFFFF);
            PC_F <= $urandom_range(0, 32'hFFFFFFFF);
            PC_Plus_4_F <= $urandom_range(0, 32'hFFFFFFFF);
            @(posedge CLK);
        end
    end
    endtask

    // Assert register resets to 0 when reset is asserted
    assertRegisterReset: assert property (@(posedge CLK) (RST == 1 |-> ##1 (Instr_D == 32'h0 && PC_D == 32'h0 && PC_Plus_4_D == 32'h0))) 
        else $error("Error: Register did not reset correctly, expected all 0 values but got instruction %h, PC %h, PC+4 %h", $sampled(Instr_D), $sampled(PC_D), $sampled(PC_Plus_4_D));

    // Assert register keeps the same value when stall is asserted
    assertRegisterStall: assert property (@(posedge CLK) ((RST == 0 && Stall_En == 1) |-> ##1 (Instr_D == $past(Instr_D) && PC_D == $past(PC_D) && PC_Plus_4_D == $past(PC_Plus_4_D)))) 
        else $error("Error: Register did not stall correctly, expected instruction %h, PC %h, PC+4 %h but got instruction %h, PC %h, PC+4 %h", $sampled($past(Instr_D)), $sampled($past(PC_D)), $sampled($past(PC_Plus_4_D)), $sampled(Instr_D), $sampled(PC_D), $sampled(PC_Plus_4_D));

    // Assert register inserts a NOP when flush is asserted
    assertRegisterFlush: assert property (@(posedge CLK) ((RST == 0 && Stall_En == 0 && Flush_D == 1) |-> ##1 (Instr_D == 32'h0000_0013 && PC_D == 32'h2A2A_2A2A && PC_Plus_4_D == 32'h2A2A_2A2A))) 
        else $error("Error: Register did not flush correctly, expected instruction 0x00000013, PC 0x2A2A2A2A, PC+4 0x2A2A2A2A but got instruction %h, PC %h, PC+4 %h", $sampled(Instr_D), $sampled(PC_D), $sampled(PC_Plus_4_D));

    // Assert register passes data through when supposed to (control signals low)
    assertRegisterNormal: assert property (@(posedge CLK) ((RST == 0 && Stall_En == 0 && Flush_D == 0) |-> ##1 (Instr_D == $past(Instr_F) && PC_D == $past(PC_F) && PC_Plus_4_D == $past(PC_Plus_4_F)))) 
        else $error("Error: Register did not pass data correctly, expected instruction %h, PC %h, PC+4 %h but got instruction %h, PC %h, PC+4 %h", $sampled($past(Instr_F)), $sampled($past(PC_F)), $sampled($past(PC_Plus_4_F)), $sampled(Instr_D), $sampled(PC_D), $sampled(PC_Plus_4_D));

endmodule