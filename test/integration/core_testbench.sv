//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Decode to Execute Pipeline Register Testbench                                                  
// Description: Tests that the pipeline register responds to control signals correctly and passes data through.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                            
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module idex_pipeline_register_testbench ();
    // Global control signals
    logic CLK, RST

    logic Branch_Taken_E,
    logic [31:0] ALU_Out_E,
    logic [31:0] PC_Target_E

    core core (
        .CLK(CLK),
        .RST(RST),
    )

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