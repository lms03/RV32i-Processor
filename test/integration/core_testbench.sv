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
    logic CLK_50MHZ_R;
    logic FPGA_SW1;
    logic FPGA_RED1, FPGA_RED2;
    logic FPGA_YEL1, FPGA_YEL2;
    logic FPGA_GRN1, FPGA_GRN2;
    logic FPGA_BLU1, FPGA_BLU2;
    logic FPGA_LED_NEN;

    core core (
        .CLK_50MHZ_R(CLK_50MHZ_R),
        .FPGA_SW1(FPGA_SW1),
        .FPGA_RED1(FPGA_RED1),
        .FPGA_RED2(FPGA_RED2),
        .FPGA_YEL1(FPGA_YEL1),
        .FPGA_YEL2(FPGA_YEL2),
        .FPGA_GRN1(FPGA_GRN1),
        .FPGA_GRN2(FPGA_GRN2),
        .FPGA_BLU1(FPGA_BLU1),
        .FPGA_BLU2(FPGA_BLU2),
        .FPGA_LED_NEN(FPGA_LED_NEN)
    );

    initial CLK_50MHZ_R <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK_50MHZ_R <= ~CLK_50MHZ_R; // Generate the clock

    initial begin
        FPGA_SW1 <= 1;
        repeat (10) @ (posedge CLK_50MHZ_R);
        FPGA_SW1 <= 0;
        @ (posedge CLK_50MHZ_R);
        FPGA_SW1 <= 1;
        repeat (500) @ (posedge CLK_50MHZ_R); 
        $stop;
    end
endmodule