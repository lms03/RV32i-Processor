//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Program Counter Testbench                                                   
// Description: This is a testbench to ensure that the instruction memory loads and fetches instructions correctly.
// Author: Luke Shepherd                                                     
// Date Modified: January 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::CLOCK_PERIOD;

module instruction_memory_testbench;
    `define MAX_CYCLES 50 // Control sim length
    logic CLK; // Wrap module with a clock to better represent the outside system
    logic [31:0] PC_Out;
    logic [31:0] Instr;

    instruction_memory imem (
        .PC_Out(PC_Out),
        .Instr(Instr)
    );

    logic [31:0] Reference [0:255]; // Memory to compare against

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        $readmemh("src/program.hex", Reference); // Load the file to check with

        @(posedge CLK);
        PC_Out <= 0;  // Initialize PC

        repeat (`MAX_CYCLES) @ (posedge CLK); // Run some time to allow for all instructions to be read
        $stop; 
    end

    always @ (posedge CLK) begin
        PC_Out <= PC_Out + 4; // Simulate the PC incrementing normally
    end

    assertInstrCorrect: assert property (@(posedge CLK) Instr === Reference[PC_Out[31:2]])
            else $error("Mismatch at address %h: got %h, expected %h", PC_Out, Instr, Reference[PC_Out[31:2]]);
    
endmodule