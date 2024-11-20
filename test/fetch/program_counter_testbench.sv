//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Program Counter Testbench                                                      
// Description: Tests for the program counter module.        
// Author: Luke Shepherd                                                     
// Date Created: November 2024                                                                                                                                                                                                                                                   
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module program_counter_testbench ();
    `define MAX_CYCLES 50 // Control sim length

    reg CLK;
    reg RST;
    reg PC_En;
    reg [31:0] PC_In;
    wire [31:0] PC_Out;

    program_counter pc (
        .CLK(CLK),
        .RST(RST),
        .PC_En(PC_En),
        .PC_In(PC_In),
        .PC_Out(PC_Out)
    );

    // Adder to increment PC to PC+4
    adder pc_adder (
        .A(PC_Out),
        .B(32'h4),
        .OUT(PC_In)
    );

    // Generate the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK;

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

        #(CLOCK_PERIOD * 2) RST = 1;  // Test reset
        #(CLOCK_PERIOD * 2) PC_En = 0;  // Test stall 
        #(CLOCK_PERIOD * 2) PC_En = 1;
    end

    // Ensure PC is reset to 0 when RST is high
    assertPCReset: assert property (@(posedge CLK) (RST == 1 |-> ##1 PC_Out == 32'h0))
        else $warning("Warning: PC did not reset correctly");

    // Ensure PC increments by 4 when PC_En is high (TEMP until branching added)
    assertPCIncrement: assert property (@(posedge CLK) (RST == 0 && PC_En == 1 |-> ##1 PC_Out == $past(PC_Out) + 32'h4))
        else $warning("Warning: PC did not increment correctly");

    // Ensure PC stalls when PC_En is low
    assertPCStall: assert property (@(posedge CLK) (RST == 0 && PC_En == 0 |-> ##1 PC_Out == $past(PC_Out)))
        else $warning("Warning: PC did not stall correctly");

endmodule