//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Core                                           
// Description: Instantiates all modules and connects them together               
// Author: Luke Shepherd                                                     
// Date Modified: December 2024                                                                                                                                                                                                                                                           
//////////////////////////////////////////////////////////////////////////////////

module core (
    input wire CLK_50MHZ_R,
    input wire FPGA_SW1, 
    output wire FPGA_RED1, FPGA_RED2,
    output wire FPGA_YEL1, FPGA_YEL2,
    output wire FPGA_GRN1, FPGA_GRN2,
    output wire FPGA_BLU1, FPGA_BLU2,
    output wire FPGA_LED_NEN // Active low
    );

    wire CLK, RST;  
    wire RED_LED, GRN_LED, YEL_LED;
    wire locked;

    assign RST = !locked || !FPGA_SW1;
    
    // assign locked = 1'b1; // Always locked
    // assign CLK = CLK_50MHZ_R; // 50 MHz clock

    clk_wiz_0 clk_mult(.clk_out1(CLK),                     /* 40 MHz system clock */
                    .clk_in1(CLK_50MHZ_R),              /* 50 MHz clk in       */
                    .locked(locked));           /* inverted and used for reset */

    assign FPGA_LED_NEN = 1'b0; // Permanent enable
    assign FPGA_BLU1 = 1'b0; // LEDs permanantly off
    assign FPGA_BLU2 = 1'b0;
    assign FPGA_YEL1 = YEL_LED; 
    assign FPGA_YEL2 = YEL_LED;
    assign FPGA_RED1 = RED_LED;
    assign FPGA_RED2 = RED_LED;
    assign FPGA_GRN1 = GRN_LED;
    assign FPGA_GRN2 = GRN_LED;

    // Fetch Signals
    wire PC_En;
    wire [31:0] PC_F, PC_Plus_4_F;
    wire Predict_Taken_F, Valid_F;

    // Decode Signals
    wire Flush_D, Stall_En;
    wire [31:0] Instr_D, PC_D, PC_Plus_4_D;
    wire REG_W_En_D, MEM_W_En_D, Jump_En_D, Branch_En_D;
    wire [2:0] MEM_Control_D;
    wire [3:0] ALU_Control_D;
    wire Branch_Src_Sel_D;
    wire ALU_SrcA_Sel_D, ALU_SrcB_Sel_D;
    wire [1:0] Result_Src_Sel_D;
    wire [4:0] RD_D, RS1_D, RS2_D;
    wire [31:0] REG_R_Data1_D, REG_R_Data2_D;
    wire [31:0] Imm_Ext_D;
    wire Predict_Taken_D, Valid_D;

    // Execute Signals
    wire Flush_E;
    wire [31:0] PC_E, PC_Plus_4_E;
    wire REG_W_En_E, MEM_W_En_E, Jump_En_E, Branch_En_E;
    wire [2:0] MEM_Control_E;
    wire [3:0] ALU_Control_E;
    wire Branch_Src_Sel_E;
    wire ALU_SrcA_Sel_E, ALU_SrcB_Sel_E;
    wire [1:0] FWD_SrcA, FWD_SrcB;
    wire [1:0] Result_Src_Sel_E;
    wire [4:0] RD_E, RS1_E, RS2_E;
    wire [31:0] REG_R_Data1_E, REG_R_Data2_E;
    wire [31:0] SrcB_Reg_E;
    wire [31:0] Imm_Ext_E;
    wire Branch_Taken_E;
    wire [31:0] ALU_Out_E, PC_Target_E;
    wire Predict_Taken_E, Valid_E;

    // Memory Signals
    wire REG_W_En_M, MEM_W_En_M;
    wire [2:0] MEM_Control_M;
    wire [1:0] Result_Src_Sel_M;
    wire [4:0] RD_M;
    wire [31:0] SrcB_Reg_M;
    wire [31:0] ALU_Out_M;
    wire [31:0] PC_Plus_4_M;
    wire [31:0] Data_Out_Ext_M;

    // Writeback Signals
    wire REG_W_En_W;
    wire [1:0] Result_Src_Sel_W;
    wire [31:0] Data_Out_Ext_W;
    wire [31:0] ALU_Out_W;
    wire [31:0] PC_Plus_4_W;
    wire [4:0] REG_W_Addr_W;
    wire [31:0] REG_W_Data_W;

    fetch fetch (
        .CLK(CLK),
        .RST(RST),
        .PC_En(PC_En),
        .Predict_Taken_E(Predict_Taken_E),
        .Branch_Taken_E(Branch_Taken_E),
        .Valid_E(Valid_E),
        .PC_Plus_4_E(PC_Plus_4_E),
        .PC_Target_E(PC_Target_E),
        .PC_E(PC_E),
        // ------------------------------ 
        .PC_F(PC_F),
        .PC_Plus_4_F(PC_Plus_4_F),
        .Predict_Taken_F(Predict_Taken_F),
        .Valid_F(Valid_F)
    );

    ifid_register ifid_reg (
        .CLK(CLK),
        .RST(RST),
        .Flush_D(Flush_D), 
        .Stall_En(Stall_En), 
        .PC_F(PC_F),
        .PC_Plus_4_F(PC_Plus_4_F),
        .Predict_Taken_F(Predict_Taken_F),
        .Valid_F(Valid_F),
        // ------------------------------
        .PC_D(PC_D),
        .PC_Plus_4_D(PC_Plus_4_D),
        .Predict_Taken_D(Predict_Taken_D),
        .Valid_D(Valid_D)
    );

    decode decode (
        .CLK(CLK),
        .RST(RST),
        .Instr_D(Instr_D),
        .REG_W_En_W(REG_W_En_W),
        .Result_W(REG_W_Data_W),
        .RD_W(REG_W_Addr_W),
        // ------------------------------
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
        .RED_LED(RED_LED),
        .GRN_LED(GRN_LED),
        .YEL_LED(YEL_LED)
    );

    idex_register idex_reg (
        .CLK(CLK),
        .RST(RST),
        .Flush_E(Flush_E),
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
        .Predict_Taken_D(Predict_Taken_D),
        .Valid_D(Valid_D),
        // ------------------------------
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
        .PC_Plus_4_E(PC_Plus_4_E),
        .Predict_Taken_E(Predict_Taken_E),
        .Valid_E(Valid_E)
    );

    execute execute (
        .Jump_En_E(Jump_En_E),
        .Branch_En_E(Branch_En_E),
        .ALU_Control_E(ALU_Control_E),
        .Branch_Src_Sel_E(Branch_Src_Sel_E),
        .ALU_SrcA_Sel_E(ALU_SrcA_Sel_E),
        .ALU_SrcB_Sel_E(ALU_SrcB_Sel_E),
        .FWD_SrcA(FWD_SrcA),
        .FWD_SrcB(FWD_SrcB),
        .REG_R_Data1_E(REG_R_Data1_E),
        .REG_R_Data2_E(REG_R_Data2_E),
        .ALU_Out_M(ALU_Out_M),
        .Result_W(REG_W_Data_W),
        .Imm_Ext_E(Imm_Ext_E),
        .PC_E(PC_E),
        // ------------------------------
        .Branch_Taken_E(Branch_Taken_E),
        .ALU_Out_E(ALU_Out_E),
        .PC_Target_E(PC_Target_E),
        .SrcB_Reg_E(SrcB_Reg_E)
    );

    exmem_register exmem_reg (
        .CLK(CLK),
        .RST(RST),
        .REG_W_En_E(REG_W_En_E),
        .MEM_W_En_E(MEM_W_En_E),
        .MEM_Control_E(MEM_Control_E),
        .Result_Src_Sel_E(Result_Src_Sel_E),
        .RD_E(RD_E),
        .SrcB_Reg_E(SrcB_Reg_E),
        .ALU_Out_E(ALU_Out_E),
        .PC_Plus_4_E(PC_Plus_4_E),
        // ------------------------------
        .REG_W_En_M(REG_W_En_M),
        .MEM_W_En_M(MEM_W_En_M),
        .MEM_Control_M(MEM_Control_M),
        .Result_Src_Sel_M(Result_Src_Sel_M),
        .RD_M(RD_M),
        .SrcB_Reg_M(SrcB_Reg_M),
        .ALU_Out_M(ALU_Out_M),
        .PC_Plus_4_M(PC_Plus_4_M)
    );

    memory memory (
        .CLK(CLK),
        .RST(RST),
        .MEM_W_En_M(MEM_W_En_M),
        .MEM_Control_M(MEM_Control_M),
        .SrcB_Reg_M(SrcB_Reg_M),
        .ALU_Out_M(ALU_Out_M[11:0]),
        .PC_F(PC_F[11:2]), // PC address to fetch instructions
        .Flush_D(Flush_D), // Hazard control
        .Stall_En(Stall_En),
        // ------------------------------
        .Data_Out_Ext_M(Data_Out_Ext_M),
        .Instr_D(Instr_D) // Output instruction read straight into decode stage
    );

    memwb_register memwb_reg (
        .CLK(CLK),
        .RST(RST),
        .REG_W_En_M(REG_W_En_M),
        .Result_Src_Sel_M(Result_Src_Sel_M),
        .RD_M(RD_M),
        .Data_Out_Ext_M(Data_Out_Ext_M),
        .ALU_Out_M(ALU_Out_M),
        .PC_Plus_4_M(PC_Plus_4_M),
        // ------------------------------
        .REG_W_En_W(REG_W_En_W),
        .Result_Src_Sel_W(Result_Src_Sel_W),
        .RD_W(REG_W_Addr_W),
        .Data_Out_Ext_W(Data_Out_Ext_W),
        .ALU_Out_W(ALU_Out_W),
        .PC_Plus_4_W(PC_Plus_4_W)
    );

    writeback writeback (
        .Result_Src_Sel_W(Result_Src_Sel_W),
        .Data_Out_Ext_W(Data_Out_Ext_W),
        .ALU_Out_W(ALU_Out_W),
        .PC_Plus_4_W(PC_Plus_4_W),
        // ------------------------------
        .Result_W(REG_W_Data_W)
    );

    hazard_control_unit hazard_control_unit (
        .RS1_D(RS1_D),
        .RS2_D(RS2_D),
        .RD_E(RD_E),
        .Result_Src_Sel_E(Result_Src_Sel_E),
        .RS1_E(RS1_E),
        .RS2_E(RS2_E),
        .RD_M(RD_M),
        .REG_W_En_M(REG_W_En_M),
        .RD_W(REG_W_Addr_W),
        .REG_W_En_W(REG_W_En_W),
        .Branch_Taken_E(Branch_Taken_E),
        .Predict_Taken_E(Predict_Taken_E),
        // ------------------------------
        .FWD_SrcA(FWD_SrcA),
        .FWD_SrcB(FWD_SrcB),
        .Stall_En(Stall_En),
        .Flush_D(Flush_D),
        .Flush_E(Flush_E),
        .PC_En(PC_En)
    );
endmodule