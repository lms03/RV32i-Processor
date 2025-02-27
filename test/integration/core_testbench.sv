//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Core Testbench                                                  
// Description: Simulates the processor with the specified program.hex file.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                            
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module core_testbench ();
    // Global control signals
    logic CLK, RST;

    core core (
        .CLK(CLK),
        .RST(RST)
    );

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        // Initialize basic signals with reset
        RST <= 1;
        @(posedge CLK);
        RST <= 0;


        repeat (100) @ (posedge CLK); 
        $stop;
    end
endmodule