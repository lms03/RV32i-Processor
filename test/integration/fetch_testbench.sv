//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Fetch Testbench                                                   
// Description: This is a testbench to ensure that the fetch stage functions correctly.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::CLOCK_PERIOD;

module fetch_testbench;
    logic CLK, RST, PC_En;
    logic [31:0] Instr_F, PC_F, PC_Plus_4_F;

    fetch fetch (
        .CLK(CLK),
        .RST(RST),
        .PC_En(PC_En),
        .Instr_F(Instr_F),
        .PC_F(PC_F),
        .PC_Plus_4_F(PC_Plus_4_F)
    );

    logic [31:0] Reference [0:255]; // Memory to compare against

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        RST <= 1; // Set the PC to 0000_0000 with reset
        $readmemh("src/program.hex", Reference); // Load the file to check with
        @(posedge CLK);
        RST <= 0; 
        PC_En <= 1; // Enable the PC
        @(posedge CLK);
        repeat (10) @ (posedge CLK); // Run some time to allow for all instructions to be read
        $stop; 
    end

    assertInstrCorrect: assert property (@(posedge CLK) Instr_F === Reference[PC_F[31:2]])
            else $error("Error: Mismatch at address %h: got %h, expected %h", $sampled(PC_F), $sampled(Instr_F), $sampled(Reference[PC_F[31:2]]));
    
endmodule