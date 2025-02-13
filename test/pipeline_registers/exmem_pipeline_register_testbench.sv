//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Decode to Execute Pipeline Register Testbench                                                  
// Description: Tests that the pipeline register responds to control signals correctly and passes data through.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                            
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module exmem_pipeline_register_testbench ();
    // Global control signals
    logic CLK, RST;

    // Input signals
    logic REG_W_En_E, MEM_W_En_E; 
    logic [2:0] MEM_Control_E;
    logic [1:0] Result_Src_Sel_E;
    logic [4:0] RD_E;
    logic [31:0] REG_R_Data2_E;
    logic [31:0] ALU_Out_E;
    logic [31:0] PC_Plus_4_E;

    // Output signals
    logic REG_W_En_M, MEM_W_En_M;
    logic [2:0] MEM_Control_M;
    logic [1:0] Result_Src_Sel_M;
    logic [4:0] RD_M;
    logic [31:0] REG_R_Data2_M;
    logic [31:0] ALU_Out_M;
    logic [31:0] PC_Plus_4_M;   

    exmem_register exmem (
        // Global control signals
        .CLK(CLK),
        .RST(RST),

        // Inputs
        .REG_W_En_E(REG_W_En_E),
        .MEM_W_En_E(MEM_W_En_E),
        .MEM_Control_E(MEM_Control_E),
        .Result_Src_Sel_E(Result_Src_Sel_E),
        .RD_E(RD_E),
        .REG_R_Data2_E(REG_R_Data2_E),
        .ALU_Out_E(ALU_Out_E),
        .PC_Plus_4_E(PC_Plus_4_E),

        // Outputs
        .REG_W_En_M(REG_W_En_M),
        .MEM_W_En_M(MEM_W_En_M),
        .MEM_Control_M(MEM_Control_M),
        .Result_Src_Sel_M(Result_Src_Sel_M),
        .RD_M(RD_M),
        .REG_R_Data2_M(REG_R_Data2_M),
        .ALU_Out_M(ALU_Out_M),
        .PC_Plus_4_M(PC_Plus_4_M)
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
            REG_W_En_E <= $urandom;
            MEM_W_En_E <= $urandom;
            MEM_Control_E <= $urandom;
            Result_Src_Sel_E <= $urandom;
            RD_E <= $urandom;
            REG_R_Data2_E <= $urandom;
            ALU_Out_E <= $urandom;
            PC_Plus_4_E <= $urandom;
            @(posedge CLK);
        end
    end
    endtask

    // Assert enables resets to 0 (safe value) when reset is asserted
    assertRegisterResetEnables: assert property (@(posedge CLK) 
        ((RST == 1) |-> ##1 (REG_W_En_M == 1'b0 && MEM_W_En_M == 1'b0)))
        else $error("Error: Register did not reset correctly, expected enable signals to be zero but got REG_W_En_M %h, MEM_W_En_M %h", 
            $sampled(REG_W_En_E), $sampled(MEM_W_En_E));

    // Assert register passes enables and data correctly
    assertRegisterPassesEnables: assert property (@(posedge CLK)
        ((RST == 0) |-> ##1 (REG_W_En_M == $past(REG_W_En_E) && MEM_W_En_M == $past(MEM_W_En_E))))
        else $error("Error: Register did not pass data correctly, expected enable signals to be REG_W_En_M %h MEM_W_En_M %h but got REG_W_En_M %h MEM_W_En_M %h", 
            $sampled($past(REG_W_En_E)), $sampled($past(MEM_W_En_E)), $sampled(REG_W_En_M), $sampled(MEM_W_En_M));

    assertRegisterPassesOther: assert property (@(posedge CLK)
        ((RST == 0) |-> ##1 (MEM_Control_M == $past(MEM_Control_E) && Result_Src_Sel_M == $past(Result_Src_Sel_E) && RD_M == $past(RD_E) && REG_R_Data2_M == $past(REG_R_Data2_E) && ALU_Out_M == $past(ALU_Out_E) && PC_Plus_4_M == $past(PC_Plus_4_E))))
        else $error("Error: Register did not pass data correctly, expected MEM_Control_M %h Result_Src_Sel_M %h RD_M %h REG_R_Data2_M %h ALU_Out_M %h PC_Plus_4_M %h but got MEM_Control_M %h Result_Src_Sel_M %h RD_M %h REG_R_Data2_M %h ALU_Out_M %h PC_Plus_4_M %h", 
            $sampled($past(MEM_Control_E)), $sampled($past(Result_Src_Sel_E)), $sampled($past(RD_E)), $sampled($past(REG_R_Data2_E)), $sampled($past(ALU_Out_E)), $sampled($past(PC_Plus_4_E)),
            $sampled(MEM_Control_M), $sampled(Result_Src_Sel_M), $sampled(RD_M), $sampled(REG_R_Data2_M), $sampled(ALU_Out_M), $sampled(PC_Plus_4_M)); 
endmodule