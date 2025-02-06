//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Instruction Memory Testbench                                                   
// Description: This is a testbench to ensure that the instruction memory loads and fetches instructions correctly.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::CLOCK_PERIOD;

module instruction_memory_testbench;
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

        repeat (10) @ (posedge CLK); // Run some time to allow for all instructions to be read
        $stop; 
    end

    always @ (posedge CLK) begin
        PC_Out <= PC_Out + 4; // Simulate the PC incrementing normally
    end

    assertInstrCorrect: assert property (@(posedge CLK) Instr === Reference[PC_Out[31:2]])
            else $error("Error: Mismatch at address %h: got %h, expected %h", $sampled(PC_Out), $sampled(Instr), $sampled(Reference[PC_Out[31:2]]));
    
endmodule