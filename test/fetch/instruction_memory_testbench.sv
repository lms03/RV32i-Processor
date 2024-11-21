//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Instruction Memory Testbench                                                    
// Description: Tests that the correct instruction is output.           
// Author: Luke Shepherd                                                     
// Date Created: November 2024                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module instruction_memory_testbench ();
    `define MAX_CYCLES 50 // Control sim length
    
    reg [31:0] PC_Out;             
    wire [31:0] Instr;         

    instruction_memory imem (
        .PC_Out(PC_Out),            
        .Instr(Instr)           
    );

    reg CLK; // To drive simulation
    reg [31:0] expected_instr; // Expected instruction for verification

    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    // Generate PC
    always @(posedge CLK) begin 
        PC_Out <= PC_Out + 4;
    end

    initial begin
        // Initiliaze signals
        CLK = 0;
        PC_Out = 32'h0; 

        repeat (`MAX_CYCLES) @ (posedge CLK); // Run sim for x cycles and then terminate
        $stop
    end

    // Expected instructions based on src/program.hex
    initial begin
        case (PC_Out[9:2])
            8'h00: expected_instr = 32'h00200093; // ADDI x1, x0, 1
            8'h01: expected_instr = 32'h00300113; // ADDI x2, x0, 2
            8'h02: expected_instr = 32'h002081b3; // ADD x3, x1, x2
            8'h03: expected_instr = 32'h0000006f; // JAL x0, 0
            default: expected_instr = 32'h00000000; // Default to 0
        endcase
    end

    // Ensure instruction memory outputs the expected instruction
    assertInstrCorrect: assert property (@(posedge CLK) (Instr == expected_instr))
        else $warning("Warning: Incorrect instruction at PC = %h, expected = %h, got = %h", PC_Out, expected_instr, Instr);

endmodule