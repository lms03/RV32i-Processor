//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Control Unit Testbench                                                   
// Description: This is a testbench which aims to verify that the control unit properly decodes instructions to produce the correct control signals.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                                    
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module control_unit_testbench;
    logic CLK; // Wrap module with a clock to control the sim more easily and better represent the external system
    logic [31:0] Instr;
    logic REG_W_En, MEM_W_En, Jump_En, Branch_En;
    logic [2:0] MEM_Control;
    logic [3:0] ALU_Control;
    logic [2:0] Imm_Type_Sel;
    logic Branch_Src_Sel;
    logic ALU_SrcA_Sel, ALU_SrcB_Sel;
    logic [1:0] Result_Src_Sel ;

    control_unit cu (
        .OP(Instr[6:0]),
        .Func3(Instr[14:12]),
        .Func7(Instr[31:25]),
        .REG_W_En(REG_W_En),
        .MEM_W_En(MEM_W_En),
        .Jump_En(Jump_En),
        .Branch_En(Branch_En),
        .MEM_Control(MEM_Control),
        .ALU_Control(ALU_Control),
        .Imm_Type_Sel(Imm_Type_Sel),
        .Branch_Src_Sel(Branch_Src_Sel),
        .ALU_SrcA_Sel(ALU_SrcA_Sel),
        .ALU_SrcB_Sel(ALU_SrcB_Sel),
        .Result_Src_Sel(Result_Src_Sel)
    );

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        Instr <= 32'h0000_0000;
        @(posedge CLK); // Wait for first posedge before starting
        
        // Test R-type instruction
        Instr <= 32'h4087_01B3; // SUB x14, x8, x3
        @(posedge CLK);
        check_signals(1, 0, 0, 0, MEM_BYTE, ALU_SUB, IMM_I, BRANCH_PC, SRCA_REG, SRCB_REG, RESULT_ALU);
        
        // Test R-type instruction with different Func7
        Instr <= 32'h0087_51B3; // SRL
        @(posedge CLK);
        check_signals(1, 0, 0, 0, MEM_BYTE, ALU_SRL, IMM_I, BRANCH_PC, SRCA_REG, SRCB_REG, RESULT_ALU);

        // Test I-type instruction
        Instr <= 32'h4087_3193; //  SLTIU
        @(posedge CLK);
        check_signals(1, 0, 0, 0, MEM_BYTE, ALU_BLTU, IMM_I, BRANCH_PC, SRCA_REG, SRCB_IMM, RESULT_ALU);

        // Test JALR instruction
        Instr <= 32'h4087_01E7; //  JALR
        @(posedge CLK);
        check_signals(1, 0, 1, 0, MEM_BYTE, ALU_ADD, IMM_I, BRANCH_REG, SRCA_REG, SRCB_IMM, RESULT_PC4);

        // Test load instruction
        Instr <= 32'h4087_2183; //  LW
        @(posedge CLK);
        check_signals(1, 0, 0, 0, MEM_WORD, ALU_ADD, IMM_I, BRANCH_PC, SRCA_REG, SRCB_IMM, RESULT_MEM);

        // Test store instruction
        Instr <= 32'h4087_01A3; //  SB
        @(posedge CLK);
        check_signals(0, 1, 0, 0, MEM_BYTE, ALU_ADD, IMM_S, BRANCH_PC, SRCA_REG, SRCB_IMM, RESULT_ALU);

        // Test branch instruction
        Instr <= 32'h4087_71E3; // BGEU 
        @(posedge CLK);
        check_signals(0, 0, 0, 1, MEM_BYTE, ALU_BGEU, IMM_B, BRANCH_PC, SRCA_REG, SRCB_REG, RESULT_ALU);

        // Test upper immediate instruction
        Instr <= 32'h4087_7197; //  AUIPC
        @(posedge CLK);
        check_signals(1, 0, 0, 0, MEM_BYTE, ALU_ADD, IMM_U, BRANCH_PC, SRCA_PC, SRCB_IMM, RESULT_ALU);

        // Test upper immediate instruction
        Instr <= 32'h4087_71B7; //  LUIPC
        @(posedge CLK);
        check_signals(1, 0, 0, 0, MEM_BYTE, ALU_LUI, IMM_U, BRANCH_PC, SRCA_REG, SRCB_IMM, RESULT_ALU);

        // Test jump instruction
        Instr <= 32'h4087_71EF; //  JAL
        @(posedge CLK);
        check_signals(1, 0, 1, 0, MEM_BYTE, ALU_ADD, IMM_J, BRANCH_PC, SRCA_REG, SRCB_REG, RESULT_PC4);

        // Test illegal instruction ensures no effect on state
        Instr <= 32'h4087_018F; // FENCE  
        @(posedge CLK);
        check_signals(0, 0, 0, 0, MEM_BYTE, ALU_ADD, IMM_I, BRANCH_PC, SRCA_REG, SRCB_REG, RESULT_ALU);

        // Test unsupported illegal instruction ensures no effect on state
        Instr <= 32'h0287_01B3; //  MUL
        @(posedge CLK);
        check_signals(0, 0, 0, 0, MEM_BYTE, ALU_ADD, IMM_I, BRANCH_PC, SRCA_REG, SRCB_REG, RESULT_ALU);
        
        repeat (5) @ (posedge CLK); // Allow some extra time at the end for visual clarity
        $stop; 
    end

    task check_signals(
        input logic expected_REG_W_En,
        input logic expected_MEM_W_En,
        input logic expected_Jump_En,
        input logic expected_Branch_En,
        input logic [2:0] expected_MEM_Control,
        input logic [3:0] expected_ALU_Control,
        input logic [2:0] expected_Imm_Type_Sel,
        input logic expected_Branch_Src_Sel,
        input logic expected_ALU_SrcA_Sel,
        input logic expected_ALU_SrcB_Sel,
        input logic [1:0] expected_Result_Src_Sel
    );
    begin
        assert (REG_W_En == expected_REG_W_En) else $error("Error: Incorrect REG_W_En produced, expected %h, got %h", expected_REG_W_En, $sampled(REG_W_En));
        assert (MEM_W_En == expected_MEM_W_En) else $error("Error: Incorrect MEM_W_En produced, expected %h, got %h", expected_MEM_W_En, $sampled(MEM_W_En));
        assert (Jump_En == expected_Jump_En) else $error("Error: Incorrect Jump_En produced, expected %h, got %h", expected_Jump_En, $sampled(Jump_En));
        assert (Branch_En == expected_Branch_En) else $error("Error: Incorrect Branch_En produced, expected %h, got %h", expected_Branch_En, $sampled(Branch_En));
        assert (MEM_Control == expected_MEM_Control) else $error("Error: Incorrect MEM_Control produced, expected %h, got %h", expected_MEM_Control, $sampled(MEM_Control));
        assert (ALU_Control == expected_ALU_Control) else $error("Error: Incorrect ALU_Control produced, expected %h, got %h", expected_ALU_Control, $sampled(ALU_Control));
        assert (Imm_Type_Sel == expected_Imm_Type_Sel) else $error("Error: Incorrect Imm_Type_Sel produced, expected %h, got %h", expected_Imm_Type_Sel, $sampled(Imm_Type_Sel));
        assert (Branch_Src_Sel == expected_Branch_Src_Sel) else $error("Error: Incorrect Branch_Src_Sel produced, expected %h, got %h", expected_Branch_Src_Sel, $sampled(Branch_Src_Sel));
        assert (ALU_SrcA_Sel == expected_ALU_SrcA_Sel) else $error("Error: Incorrect ALU_SrcA_Sel produced, expected %h, got %h", expected_ALU_SrcA_Sel, $sampled(ALU_SrcA_Sel));
        assert (ALU_SrcB_Sel == expected_ALU_SrcB_Sel) else $error("Error: Incorrect ALU_SrcB_Sel produced, expected %h, got %h", expected_ALU_SrcB_Sel, $sampled(ALU_SrcB_Sel));
        assert (Result_Src_Sel == expected_Result_Src_Sel) else $error("Error: Incorrect Result_Src_Sel produced, expected %h, got %h", expected_Result_Src_Sel, $sampled(Result_Src_Sel));
    end
    endtask
endmodule