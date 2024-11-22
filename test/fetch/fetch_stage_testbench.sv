//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Program Counter Testbench                                                      
// Description: Tests that the program counter outputs the correct value. 
// Author: Luke Shepherd                                                     
// Date Created: November 2024                                                                                                                                                                                                                                                   
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module fetch_stage_testbench ();
    `define MAX_CYCLES 50 // Control sim length

    reg CLK;
    reg RST;
    reg PC_En;
    wire [31:0] PC_Out;
    wire [31:0] PC_Plus_4;
    wire [31:0] Instr;

    fetch fetch (
        .CLK(CLK),
        .RST(RST),
        .PC_En(PC_En),
        .Instr(Instr),
        .PC_Out(PC_Out),
        .PC_Plus_4(PC_Plus_4)
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
        PC_In = 32'h0; 
        PC_En = 1;
        #(CLOCK_PERIOD * 2) RST = 0; // Start test after delay for propagation and visual clarity
        // Replace with repeats potentially.
        #(CLOCK_PERIOD * 2) RST = 1;  // Test reset
        #(CLOCK_PERIOD * 2) PC_En = 0;  // Test stall 
        #(CLOCK_PERIOD * 2) PC_En = 1;
    end

    always @ (PC) begin
        case (PC[9:2])
            8'h00: expected_instr = 32'h00200093; // ADDI x1, x0, 1
            8'h01: expected_instr = 32'h00300113; // ADDI x2, x0, 2
            8'h02: expected_instr = 32'h002081b3; // ADD x3, x1, x2
            8'h03: expected_instr = 32'h0000006f; // JAL x0, 0
            default: expected_instr = 32'h00000000; // Default to 0
        endcase
    end

    // Ensure PC is reset to 0 when RST is high
    assertPCReset: assert property (@(posedge CLK) (RST == 1 |-> ##1 PC == 32'h0))
        else $warning("Warning: PC did not reset correctly");

    // Ensure PC increments by 4 when PC_En is high (TEMP until branching added)
    assertPCIncrement: assert property (@(posedge CLK) (RST == 0 && PC_En == 1 |-> ##1 PC == $past(PC) + 32'h4))
        else $warning("Warning: PC did not increment correctly");

    // Ensure PC stalls when PC_En is low
    assertPCStall: assert property (@(posedge CLK) (RST == 0 && PC_En == 0 |-> ##1 PC == $past(PC)))
        else $warning("Warning: PC did not stall correctly");

    // Ensure instruction memory outputs the expected instruction
    assertInstrCorrect: assert property (@(posedge CLK) (Instr == expected_instr))
        else $warning("Warning: Incorrect instruction at PC = %h, expected = %h, got = %h", PC, expected_instr, Instr);

endmodule