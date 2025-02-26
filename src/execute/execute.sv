//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Execute                                                   
// Description: Holds all Execute stage modules.
//              ALU: 
//                  Performs arithmetic and logical operations on two operands.
// Date Modified: February 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module execute (
    // Control unit signals
    input wire Jump_En_E, Branch_En_E,
    input wire [3:0] ALU_Control_E,
    input wire Branch_Src_Sel_E,
    input wire ALU_SrcA_Sel_E, ALU_SrcB_Sel_E,

    // Register data
    input wire [31:0] REG_R_Data1_E, REG_R_Data2_E,

    // Extended Immediate
    input wire [31:0] Imm_Ext_E,

    // PC
    input wire [31:0] PC_E,

    // -----------------------------------------------------------
    
    // Outputs
    output wire Branch_Taken_E,
    output wire [31:0] ALU_Out_E,
    output wire [31:0] PC_Target_E
    );

    wire [31:0] SrcA, SrcB;
    wire Branch_Out;
    wire [31:0] Branch_Src;

    arithmetic_logic_unit alu (
        .ALU_Control(ALU_Control_E),
        .SrcA(SrcA),
        .SrcB(SrcB),
        .Result(ALU_Out_E),
        .Branch_Condition(Branch_Out)
    );

    mux2_1 mux2_1_srca (
        .SEL(ALU_SrcA_Sel_E),
        .IN1(REG_R_Data1_E), // Replace later with output from forwarding mux
        .IN2(PC_E),
        .OUT(SrcA)
    );

    mux2_1 mux2_1_srcb (
        .SEL(ALU_SrcB_Sel_E),
        .IN1(REG_R_Data2_E), // Replace later with output from forwarding mux
        .IN2(Imm_Ext_E),
        .OUT(SrcB)
    );

    mux2_1 mux2_1_branch (
        .SEL(Branch_Src_Sel_E),
        .IN1(PC_E), 
        .IN2(REG_R_Data1_E),
        .OUT(Branch_Src)
    );

    adder32 target_adder (
        .A(Branch_Src),
        .B(Imm_Ext_E),
        .OUT(PC_Target_E)
    );

    assign Branch_Taken_E = Jump_En_E | (Branch_En_E & Branch_Out);
endmodule

module arithmetic_logic_unit (
    input wire [3:0] ALU_Control,
    input wire [31:0] SrcA, SrcB,
    output logic [31:0] Result,
    output logic Branch_Condition
    );
    
    // ALU operations
    always_comb begin
        Result = 32'b0; // Default values
        Branch_Condition = 1'b0;
        case (ALU_Control)
            ALU_ADD: Result = SrcA + SrcB;
            ALU_SUB: Result = SrcA - SrcB;
            ALU_AND: Result = SrcA & SrcB;
            ALU_OR: Result = SrcA | SrcB;
            ALU_XOR: Result = SrcA ^ SrcB;
            ALU_SLL: Result = SrcA << SrcB;
            ALU_SRL: Result = SrcA >> SrcB;
            ALU_SRA: Result = $signed(SrcA) >>> SrcB;
            ALU_BEQ: 
                begin
                    if (SrcA == SrcB) Branch_Condition = 1'b1;
                    else Branch_Condition = 1'b0; 
                end
            ALU_BNE: 
                begin
                    if (SrcA != SrcB) Branch_Condition = 1'b1;
                    else Branch_Condition = 1'b0;
                end
            ALU_BLT:
                begin
                    if ($signed(SrcA) < $signed(SrcB)) 
                    begin 
                        Branch_Condition = 1'b1;
                        Result = 32'b1; // Result for SLT
                    end
                    else 
                    begin 
                        Branch_Condition = 1'b0;
                        Result = 32'b0; // Result for SLT
                    end
                end
            ALU_BLTU: 
                begin
                    if (SrcA < SrcB) 
                    begin  
                        Branch_Condition = 1'b1;
                        Result = 32'b1; // Result for SLTU
                    end
                    else 
                    begin 
                        Branch_Condition = 1'b0;
                        Result = 32'b0; // Result for SLTU
                    end
                end
            ALU_BGE: 
                begin
                    if ($signed(SrcA) >= $signed(SrcB)) Branch_Condition = 1'b1;
                    else Branch_Condition = 1'b0;
                end
            ALU_BGEU: 
                begin
                    if (SrcA >= SrcB) Branch_Condition = 1'b1;
                    else Branch_Condition = 1'b0;
                end
            ALU_LUI: Result = SrcB;
            default: Result = 32'bX; // Propagate X to indicate error
        endcase
    end
endmodule