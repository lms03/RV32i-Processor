//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Memory to Writeback Pipeline Register Testbench                                                  
// Description: Tests that the pipeline register responds to control signals correctly and passes data through.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                            
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module memwb_pipeline_register_testbench ();
    // Global control signals
    logic CLK, RST;

    // Input signals
    logic REG_W_En_M; 
    logic [1:0] Result_Src_Sel_M;
    logic [4:0] RD_M;
    logic [31:0] MEM_Out_M;
    logic [31:0] ALU_Out_M;
    logic [31:0] PC_Plus_4_M;

    // Output signals
    logic REG_W_En_W;
    logic [1:0] Result_Src_Sel_W;
    logic [4:0] RD_W;
    logic [31:0] MEM_Out_W;
    logic [31:0] ALU_Out_W;
    logic [31:0] PC_Plus_4_W;   

    exmem_register exmem (
        // Global control signals
        .CLK(CLK),
        .RST(RST),

        // Inputs
        .REG_W_En_M(REG_W_En_M),
        .Result_Src_Sel_M(Result_Src_Sel_M),
        .RD_M(RD_M),
        .MEM_Out_M(MEM_Out_M),
        .ALU_Out_M(ALU_Out_M),
        .PC_Plus_4_M(PC_Plus_4_M),

        // Outputs
        .REG_W_En_W(REG_W_En_W),
        .Result_Src_Sel_W(Result_Src_Sel_W),
        .RD_W(RD_W),
        .MEM_Out_W(MEM_Out_W),
        .ALU_Out_W(ALU_Out_W),
        .PC_Plus_4_W(PC_Plus_4_W)
    );
    
    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        // Initialize basic signals with reset
        RST <= 1;
        @(posedge CLK);
        RST <= 0;

        // Test reset
        operate(5);
        RST <= 1;
        @(posedge CLK);
        RST <= 0;

        // Test normal operation and then end
        operate(5);
        $stop;
    end

    task operate(int duration); begin
        for (int i = 0; i < duration; i++) begin
            REG_W_En_M <= $urandom;
            Result_Src_Sel_M <= $urandom;
            RD_M <= $urandom;
            MEM_Out_M <= $urandom;
            ALU_Out_M <= $urandom;
            PC_Plus_4_M <= $urandom;
            @(posedge CLK);
        end
    end
    endtask

    // Assert enables resets to 0 (safe value) when reset is asserted
    assertRegisterResetEnables: assert property (@(posedge CLK) 
        ((RST == 1) |-> ##1 (REG_W_En_W == 1'b0)))
        else $error("Error: Register did not reset correctly, expected REG_W_En_W to be zero but got %h", $sampled(REG_W_En_W));

    // Assert register passes enables and data correctly
    assertRegisterPassesEnables: assert property (@(posedge CLK)
        ((RST == 0) |-> ##1 (REG_W_En_W == $past(REG_W_En_M))))
        else $error("Error: Register did not pass data correctly, expected REG_W_En_W to be %h but got REG_W_En_W %h", 
            $sampled($past(REG_W_En_M)), $sampled(REG_W_En_W));

    assertRegisterPassesOther: assert property (@(posedge CLK)
        ((RST == 0) |-> ##1 (Result_Src_Sel_W == $past(Result_Src_Sel_M) && RD_W == $past(RD_M) && MEM_Out_W == $past(MEM_Out_M) && ALU_Out_W == $past(ALU_Out_M) && PC_Plus_4_W == $past(PC_Plus_4_M))))
        else $error("Error: Register did not pass data correctly, expected Result_Src_Sel_W %h RD_W %h MEM_Out_W %h ALU_Out_W %h PC_Plus_4_W %h but got Result_Src_Sel_W %h RD_W %h MEM_Out_W %h ALU_Out_W %h PC_Plus_4_W %h", 
            $sampled($past(Result_Src_Sel_M)), $sampled($past(RD_M)), $sampled($past(MEM_Out_M)), $sampled($past(ALU_Out_M)), $sampled($past(PC_Plus_4_M)),
            $sampled(Result_Src_Sel_W), $sampled(RD_W), $sampled(MEM_Out_W), $sampled(ALU_Out_W), $sampled(PC_Plus_4_W)); 
endmodule