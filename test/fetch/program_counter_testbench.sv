//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Program Counter Testbench                                                   
// Description: This is a testbench to ensure that the program counter resets, stalls and updates correctly.
// Author: Luke Shepherd                                                     
// Date Modified: January 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::CLOCK_PERIOD;

module program_counter_testbench ();
    logic CLK;
    logic RST;
    logic PC_En;
    logic [31:0] PC_In;
    logic [31:0] PC_Out;

    program_counter pc (
        .CLK(CLK),
        .RST(RST),
        .PC_En(PC_En),
        .PC_In(PC_In),
        .PC_Out(PC_Out)
    );

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        // Initiliaze signals with reset and stall
        RST <= 1;
        PC_En <= 0;
        PC_In <= 32'h0; // Set min value
        @(posedge CLK);
        RST <= 0;
        PC_En <= 1;

        // Test that the PC updates correctly with interesting values
        PC_In <= 32'hFFFF_FFFE; // Set max - 1 value
        @(posedge CLK);
        PC_In <= 32'hFFFF_FFFF; // Set max value
        @(posedge CLK); 

        operate(10); // Simulate operation for up to 10 cycles

        // Test that the PC stalls correctly
        PC_En <= 0;
        repeat ($random & 20) @ (posedge CLK); // Random stall duration
        PC_En <= 1;
        PC_In <= 32'h8;
        @(posedge CLK);

        operate(10);

        // Test reset during operation
        RST <= 1; 
        repeat (1) @ (posedge CLK);
        RST <= 0;
        @(posedge CLK);

        operate(30); // Let it run for a while longer in a stable state

        repeat (5) @ (posedge CLK);  // Run sim for 5 extra cycles and then terminate
        $stop;
    end

    // Update the PC with random values for a random duration to simulate operation
    task operate(input int max_duration); begin
        int duration = $random & max_duration; 
        for (int i = 0; i < duration; i++) begin
            PC_In <= $random;
            @(posedge CLK);
        end
	end
    endtask

    // Ensure PC is reset to 0 when RST is high
    assertPCReset: assert property (@(posedge CLK) (RST === 1 |-> ##1 PC_Out === 32'h0))
        else $warning("Warning: PC did not reset correctly");

    // Ensure PC updates when the input to the module is updated
    assertPCIncrement: assert property (@(posedge CLK) (RST === 0 && PC_En === 1 |-> ##1 PC_Out === $past(PC_In)))
        else $warning("Warning: PC did not increment correctly");

    // Ensure PC stalls and retains the same output
    assertPCStall: assert property (@(posedge CLK) (RST === 0 && PC_En === 0 |-> ##1 PC_Out === $past(PC_Out)))
        else $warning("Warning: PC did not stall correctly");

endmodule