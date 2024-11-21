//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Fetch to Decode Pipeline Register Testbench                                                  
// Description: Tests that the pipeline register responds to control signals correctly and passes data through.
// Author: Luke Shepherd                                                     
// Date Created: November 2024                                                                                                                                                                                                                                                   
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module ifid_pipeline_register_testbench ();
    `define MAX_CYCLES 50 // Control sim length

    reg CLK;
    reg RST;
    reg Flush_D;
    reg Stall_En;
    reg [31:0] Instr_F;
    reg [31:0] PC_F;
    reg [31:0] PC_Plus_4_F;
    wire [31:0] Instr_D;
    wire [31:0] PC_D;
    wire [31:0] PC_Plus_4_D;

    ifid_reg ifid (
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

    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        repeat (`MAX_CYCLES) @ (posedge CLK);  // Run sim for x cycles and then terminate
        $stop;
    end

    initial begin
        // Initiliaze signals
        CLK = 0;
        RST = 1;
        Flush_D = 0;
        Stall_En = 0;
        Instr_F = 32'h0;
        PC_F = 32'h0;
        PC_Plus_4_F = 32'h0;

        // Add tests check control signals and data flow.
    end

    // Add assertions here.
endmodule