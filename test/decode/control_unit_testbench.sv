//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Control Unit Testbench                                                   
// Description: This is a testbench which aims to verify that the control unit properly decodes instructions to produce the correct control signals.
// Author: Luke Shepherd                                                     
// Date Modified: January 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module control_unit_testbench;
    logic CLK; // Wrap module with a clock to control the sim more easily and better represent the external system
    logic [6:0] OP;
    logic [2:0] Func3;
    logic Func7;
    logic REG_W_En, MEM_W_En, Jump_En, Branch_En;
    logic [2:0] MEM_Control;
    logic [3:0] ALU_Control;
    logic [2:0] Imm_Type_Sel;
    logic Branch_Src_Sel;
    logic ALU_SrcA_Sel, ALU_SrcB_Sel;
    logic [1:0] Result_Src_Sel ;

    control_unit cu (
        .OP(OP),
        .Func3(Func3),
        .Func7(Func7),
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
        @(posedge CLK); // Wait for first posedge before starting
        
        
        repeat (5) @ (posedge CLK); // Allow some extra time at the end for visual clarity
        $stop; 
    end
endmodule