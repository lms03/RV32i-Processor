//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Core                                           
// Description: Instantiates all modules and connects them together               
// Author: Luke Shepherd                                                     
// Date Modified: December 2024                                                                                                                                                                                                                                                           
//////////////////////////////////////////////////////////////////////////////////

module core (
    input wire CLK,
    input wire RST
    );

    // PC Signals
    wire [31:0] PC_In;
    wire [31:0] PC_Out;
    wire [31:0] PC_Plus_4;
    wire PC_En;

    fetch fetch (
        .CLK(CLK),
        .RST(RST),
        .PC_En(PC_En),
        .Instr_F(Instr_F),
        .PC_F(PC_Out),
        .PC_Plus_4_F(PC_Plus_4)
    );

    ifid_reg ifid_reg (
        .CLK(CLK),
        .RST(RST),
        .Flush_D(0), //TEMPORARY, CHANGE LATER
        .Stall_En(0), //TEMPORARY, CHANGE LATER
        .Instr_F(Instr_F),
        .PC_F(PC),
        .PC_Plus_4_F(PC_Plus_4),
        .Instr_D(Instr_D),
        .PC_D(PC_D),
        .PC_Plus_4_D(PC_Plus_4_D)
    );

endmodule