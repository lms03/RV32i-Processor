//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Decode to Execute Pipeline Register Testbench                                                  
// Description: Tests that the pipeline register responds to control signals correctly and passes data through.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                            
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module ifid_pipeline_register_testbench ();
    // Global control signals
    logic CLK, RST, Flush_E;

    // Input signals
    logic REG_W_En_D, MEM_W_En_D, Jump_En_D, Branch_En_D;
    logic [2:0] MEM_Control_D;
    logic [3:0] ALU_Control_D;
    logic Branch_Src_Sel_D;
    logic ALU_SrcA_Sel_D, ALU_SrcB_Sel_D;
    logic [1:0] Result_Src_Sel_D;
    logic [4:0] RD_D, RS1_D, RS2_D;
    logic [31:0] REG_R_Data1_D, REG_R_Data2_D;
    logic [31:0] Imm_Ext_D;
    logic [31:0] PC_D, PC_Plus_4_D;

    // Output signals
    logic REG_W_En_E, MEM_W_En_E, Jump_En_E, Branch_En_E;
    logic [2:0] MEM_Control_E;
    logic [3:0] ALU_Control_E;
    logic Branch_Src_Sel_E;
    logic ALU_SrcA_Sel_E, ALU_SrcB_Sel_E;
    logic [1:0] Result_Src_Sel_E;
    logic [4:0] RD_E, RS1_E, RS2_E;
    logic [31:0] REG_R_Data1_E, REG_R_Data2_E;
    logic [31:0] Imm_Ext_E;
    logic [31:0] PC_E, PC_Plus_4_E;

    idex_register idex (
        // Global control signals
        .CLK(CLK),
        .RST(RST),
        .Flush_E(Flush_E),

        // Input signals
        .REG_W_En_D(REG_W_En_D),
        .MEM_W_En_D(MEM_W_En_D),
        .Jump_En_D(Jump_En_D),
        .Branch_En_D(Branch_En_D),
        .MEM_Control_D(MEM_Control_D),
        .ALU_Control_D(ALU_Control_D),
        .Branch_Src_Sel_D(Branch_Src_Sel_D),
        .ALU_SrcA_Sel_D(ALU_SrcA_Sel_D),
        .ALU_SrcB_Sel_D(ALU_SrcB_Sel_D),
        .Result_Src_Sel_D(Result_Src_Sel_D),
        .RD_D(RD_D),
        .RS1_D(RS1_D),
        .RS2_D(RS2_D),
        .REG_R_Data1_D(REG_R_Data1_D),
        .REG_R_Data2_D(REG_R_Data2_D),
        .Imm_Ext_D(Imm_Ext_D),
        .PC_D(PC_D),
        .PC_Plus_4_D(PC_Plus_4_D),

        // Output signals
        .REG_W_En_E(REG_W_En_E),
        .MEM_W_En_E(MEM_W_En_E),
        .Jump_En_E(Jump_En_E),
        .Branch_En_E(Branch_En_E),
        .MEM_Control_E(MEM_Control_E),
        .ALU_Control_E(ALU_Control_E),
        .Branch_Src_Sel_E(Branch_Src_Sel_E),
        .ALU_SrcA_Sel_E(ALU_SrcA_Sel_E),
        .ALU_SrcB_Sel_E(ALU_SrcB_Sel_E),
        .Result_Src_Sel_E(Result_Src_Sel_E),
        .RD_E(RD_E),
        .RS1_E(RS1_E),
        .RS2_E(RS2_E),
        .REG_R_Data1_E(REG_R_Data1_E),
        .REG_R_Data2_E(REG_R_Data2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .PC_E(PC_E),
        .PC_Plus_4_E(PC_Plus_4_E)
    );

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        // Initialize basic signals with reset
        RST <= 1;
        Flush_E <= 0;
        @(posedge CLK);
        RST <= 0;
        Flush_E <= 0;

        // Test reset
        operate(5);
        RST <= 1;
        @(posedge CLK);
        RST <= 0;

        // Test flush
        operate(5);
        Flush_E <= 1;
        @(posedge CLK);
        Flush_E <= 0;

        // Test normal operation and then end
        operate(5);
        $stop;
    end

    task operate(int duration); begin
        for (int i = 0; i < duration; i++) begin
            REG_W_En_D <= $urandom;
            MEM_W_En_D <= $urandom;
            Jump_En_D <= $urandom;
            Branch_En_D <= $urandom;
            MEM_Control_D <= $urandom;
            ALU_Control_D <= $urandom;
            Branch_Src_Sel_D <= $urandom;
            ALU_SrcA_Sel_D <= $urandom;
            ALU_SrcB_Sel_D <= $urandom;
            Result_Src_Sel_D <= $urandom;
            RD_D <= $urandom;
            RS1_D <= $urandom;
            RS2_D <= $urandom;
            REG_R_Data1_D <= $urandom;
            REG_R_Data2_D <= $urandom;
            Imm_Ext_D <= $urandom;
            PC_D <= $urandom;
            PC_Plus_4_D <= $urandom;
            @(posedge CLK);
        end
    end
    endtask

    // Assert register resets to 0 when reset is asserted
    assertRegisterResetEnables: assert property (@(posedge CLK) 
        (RST == 1 |-> ##1 (REG_W_En_E == 1'b0 && MEM_W_En_E == 1'b0 && Jump_En_E == 1'b0 && Branch_En_E == 1'b0)))
        else $error("Error: Register did not reset correctly, expected enable signals to be reset but got REG_W_En_E %h, MEM_W_En_E %h, Jump_En_E %h, Branch_En_E %h", 
            $sampled(REG_W_En_E), $sampled(MEM_W_En_E), $sampled(Jump_En_E), $sampled(Branch_En_E));

    assertRegisterResetControls: assert property (@(posedge CLK) 
        (RST == 1 |-> ##1 (MEM_Control_E == 3'h0 && ALU_Control_E == 4'h0)))
        else $error("Error: Register did not reset correctly, expected control signals to be reset but got MEM_Control_E %h, ALU_Control_E %h", 
            $sampled(MEM_Control_E), $sampled(ALU_Control_E));

    assertRegisterResetSelects: assert property (@(posedge CLK) 
        (RST == 1 |-> ##1 (Branch_Src_Sel_E == 1'b0 && ALU_SrcA_Sel_E == 1'b0 && ALU_SrcB_Sel_E == 1'b0 && Result_Src_Sel_E == 2'h0)))
        else $error("Error: Register did not reset correctly, expected select signals to be reset but got Branch_Src_Sel_E %h, ALU_SrcA_Sel_E %h, ALU_SrcB_Sel_E %h, Result_Src_Sel_E %h", 
            $sampled(Branch_Src_Sel_E), $sampled(ALU_SrcA_Sel_E), $sampled(ALU_SrcB_Sel_E), $sampled(Result_Src_Sel_E));

    assertRegisterResetRegisterData: assert property (@(posedge CLK) 
        (RST == 1 |-> ##1 (RD_E == 5'h0 && RS1_E == 5'h0 && RS2_E == 5'h0 && REG_R_Data1_E == 32'h0 && REG_R_Data2_E == 32'h0)))
        else $error("Error: Register did not reset correctly, expected register data signals to be reset but got RD_E %h, RS1_E %h, RS2_E %h, REG_R_Data1_E %h, REG_R_Data2_E %h", 
            $sampled(RD_E), $sampled(RS1_E), $sampled(RS2_E), $sampled(REG_R_Data1_E), $sampled(REG_R_Data2_E));

    assertRegisterResetOther: assert property (@(posedge CLK) 
        (RST == 1 |-> ##1 (Imm_Ext_E == 32'h0 && PC_E == 32'h0 && PC_Plus_4_E == 32'h0)))
        else $error("Error: Register did not reset correctly, expected signals to be reset but got Imm_Ext_E %h, PC_E %h, PC_Plus_4_E %h", 
            $sampled(Imm_Ext_E), $sampled(PC_E), $sampled(PC_Plus_4_E));

    // --------------------------------------------------------

    // Assert register inserts a NOP when flush is asserted
    assertRegisterFlushEnables: assert property (@(posedge CLK) 
        ((RST == 0 && Flush_E == 1) |-> ##1 (REG_W_En_E == 1'b0 && MEM_W_En_E == 1'b0 && Jump_En_E == 1'b0 && Branch_En_E == 1'b0)))
        else $error("Error: Register did not flush correctly, expected enable signals to be reset but got REG_W_En_E %h, MEM_W_En_E %h, Jump_En_E %h, Branch_En_E %h", 
            $sampled(REG_W_En_E), $sampled(MEM_W_En_E), $sampled(Jump_En_E), $sampled(Branch_En_E));

    assertRegisterFlushControls: assert property (@(posedge CLK) 
        ((RST == 0 && Flush_E == 1) |-> ##1 (MEM_Control_E == 3'h0 && ALU_Control_E == 4'h0)))
        else $error("Error: Register did not flush correctly, expected control signals to be reset but got MEM_Control_E %h, ALU_Control_E %h", 
            $sampled(MEM_Control_E), $sampled(ALU_Control_E));

    assertRegisterFlushSelects: assert property (@(posedge CLK) 
        ((RST == 0 && Flush_E == 1) |-> ##1 (Branch_Src_Sel_E == 1'b0 && ALU_SrcA_Sel_E == 1'b0 && ALU_SrcB_Sel_E == 1'b0 && Result_Src_Sel_E == 2'h0)))
        else $error("Error: Register did not flush correctly, expected select signals to be reset but got Branch_Src_Sel_E %h, ALU_SrcA_Sel_E %h, ALU_SrcB_Sel_E %h, Result_Src_Sel_E %h", 
            $sampled(Branch_Src_Sel_E), $sampled(ALU_SrcA_Sel_E), $sampled(ALU_SrcB_Sel_E), $sampled(Result_Src_Sel_E));

    assertRegisterFlushRegisterData: assert property (@(posedge CLK) 
        ((RST == 0 && Flush_E == 1) |-> ##1 (RD_E == 5'h0 && RS1_E == 5'h0 && RS2_E == 5'h0 && REG_R_Data1_E == 32'h0 && REG_R_Data2_E == 32'h0)))
        else $error("Error: Register did not flush correctly, expected register data signals to be reset but got RD_E %h, RS1_E %h, RS2_E %h, REG_R_Data1_E %h, REG_R_Data2_E %h", 
            $sampled(RD_E), $sampled(RS1_E), $sampled(RS2_E), $sampled(REG_R_Data1_E), $sampled(REG_R_Data2_E));

    assertRegisterFlushOther: assert property (@(posedge CLK) 
        ((RST == 0 && Flush_E == 1) |-> ##1 (Imm_Ext_E == 32'h0 && PC_E == 32'h2A2A_2A2A && PC_Plus_4_E == 32'h2A2A_2A2A)))
        else $error("Error: Register did not flush correctly, expected signals to be 0x00000000 and 0x2A2A2A2A but got Imm_Ext_E %h, PC_E %h, PC_Plus_4_E %h", 
            $sampled(Imm_Ext_E), $sampled(PC_E), $sampled(PC_Plus_4_E));

    // --------------------------------------------------------

    // Assert register passes data through when supposed to (control signals low)
    assertRegisterPassesEnables: assert property (@(posedge CLK) 
        ((RST == 0 && Flush_E == 0) |-> ##1 (REG_W_En_E == $past(REG_W_En_D) && MEM_W_En_E == $past(MEM_W_En_D) && Jump_En_E == $past(Jump_En_D) && Branch_En_E == $past(Branch_En_D))))
        else $error("Error: Register did not pass data correctly, expected enable signals to be REG_W_En_E %h MEM_W_En_E %h Jump_En_E %h Branch_En_E %h but got REG_W_En_E %h MEM_W_En_E %h Jump_En_E %h Branch_En_E %h", 
            $sampled($past(REG_W_En_D)), $sampled($past(MEM_W_En_D)), $sampled($past(Jump_En_D)), $sampled($past(Branch_En_D)), $sampled(REG_W_En_E), $sampled(MEM_W_En_E), $sampled(Jump_En_E), $sampled(Branch_En_E));

    assertRegisterPassesControls: assert property (@(posedge CLK) 
        ((RST == 0 && Flush_E == 0) |-> ##1 (MEM_Control_E == $past(MEM_Control_D) && ALU_Control_E == $past(ALU_Control_D))))
        else $error("Error: Register did not pass data correctly, expected control signals to be MEM_Control_E %h ALU_Control_E %h but got MEM_Control_E %h ALU_Control_E %h", 
            $sampled(MEM_Control_D), $sampled(ALU_Control_D), $sampled(MEM_Control_E), $sampled(ALU_Control_E));

    assertRegisterPassesSelects: assert property (@(posedge CLK) 
        ((RST == 0 && Flush_E == 0) |-> ##1 (Branch_Src_Sel_E == $past(Branch_Src_Sel_D) && ALU_SrcA_Sel_E == $past(ALU_SrcA_Sel_D) && ALU_SrcB_Sel_E == $past(ALU_SrcB_Sel_D) && Result_Src_Sel_E == $past(Result_Src_Sel_D))))
        else $error("Error: Register did not pass data correctly, expected select signals to be Branch_Src_Sel_E %h ALU_SrcA_Sel_E %h ALU_SrcB_Sel_E %h Result_Src_Sel_E %h but got Branch_Src_Sel_E %h ALU_SrcA_Sel_E %h ALU_SrcB_Sel_E %h Result_Src_Sel_E %h", 
            $sampled(Branch_Src_Sel_D), $sampled(ALU_SrcA_Sel_D), $sampled(ALU_SrcB_Sel_D), $sampled(Result_Src_Sel_D), $sampled(Branch_Src_Sel_E), $sampled(ALU_SrcA_Sel_E), $sampled(ALU_SrcB_Sel_E), $sampled(Result_Src_Sel_E));

    assertRegisterPassesRegisterData: assert property (@(posedge CLK) 
        ((RST == 0 && Flush_E == 0) |-> ##1 (RD_E == $past(RD_D) && RS1_E == $past(RS1_D) && RS2_E == $past(RS2_D) && REG_R_Data1_E == $past(REG_R_Data1_D) && REG_R_Data2_E == $past(REG_R_Data2_D))))
        else $error("Error: Register did not pass data correctly, expected register data signals to be RD_E %h RS1_E %h RS2_E %h REG_R_Data1_E %h REG_R_Data2_E %h but got RD_E %h RS1_E %h RS2_E %h REG_R_Data1_E %h REG_R_Data2_E %h", 
            $sampled($past(RD_D)), $sampled($past(RS1_D)), $sampled($past(RS2_D)), $sampled($past(REG_R_Data1_D)), $sampled($past(REG_R_Data2_D)), $sampled(RD_E), $sampled(RS1_E), $sampled(RS2_E), $sampled(REG_R_Data1_E), $sampled(REG_R_Data2_E));

    assertRegisterPassesOther: assert property (@(posedge CLK)
        ((RST == 0 && Flush_E == 0) |-> ##1 (Imm_Ext_E == $past(Imm_Ext_D) && PC_E == $past(PC_D) && PC_Plus_4_E == $past(PC_Plus_4_D))))
        else $error("Error: Register did not pass data correctly, expected signals to be Imm_Ext_E %h, PC_E %h, PC_Plus_4_E %h but got Imm_Ext_E %h, PC_E %h, PC_Plus_4_E %h", 
            $sampled(Imm_Ext_D), $sampled(PC_D), $sampled(PC_Plus_4_D), $sampled(Imm_Ext_E), $sampled(PC_E), $sampled(PC_Plus_4_E));

endmodule