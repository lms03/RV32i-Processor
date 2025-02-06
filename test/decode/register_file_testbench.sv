//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Register File Testbench                                                   
// Description: This is a testbench to ensure that the register file resets, reads and writes correctly.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                                
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module register_file_testbench;
    logic CLK, RST, REG_W_En;
    logic [4:0] REG_R_Addr1, REG_R_Addr2, REG_W_Addr;
    logic [31:0] REG_W_Data;
    logic [31:0] REG_R_Data1, REG_R_Data2;

    register_file regfile (
        .CLK(CLK),
        .RST(RST),
        .REG_W_En(REG_W_En),
        .REG_R_Addr1(REG_R_Addr1),
        .REG_R_Addr2(REG_R_Addr2),
        .REG_W_Addr(REG_W_Addr),
        .REG_W_Data(REG_W_Data),
        .REG_R_Data1(REG_R_Data1),
        .REG_R_Data2(REG_R_Data2)
    );

    logic [31:0] Reference [0:31]; // Registers to compare against

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        @(posedge CLK); // Wait for first posedge before starting
        RST <= 1; // Assert reset
        REG_W_En <= 0; // Disable write
        // Initialize signals
        REG_R_Addr1 <= 0; 
        REG_R_Addr2 <= 0;
        REG_W_Addr <= 0;
        REG_W_Data <= 0;
        @(posedge CLK); // Wait for next posedge to allow reset to happen
        RST <= 0; // Deassert reset

        // Assert that all registers are reset to 0
        for (int i = 0; i < 32; i++) begin
            REG_R_Addr1 <= i; // Read from each register
            @(posedge CLK);
            assert (REG_R_Data1 == 32'h0000_0000) 
                else $error("Error: Register %h did not reset correctly, expected %h, got %h", i, 32'h0000_0000, $sampled(REG_R_Data1));
        end

        // Write to interesting registers
        // Assert that writing to x0 does not change it
        REG_W_Addr <= 0; // Write to x0
        REG_W_Data <= $urandom; // Write random value to register 0
        REG_W_En <= 1; // Enable write
        @(posedge CLK); 
        REG_R_Addr1 <= 0; // Set read to x0
        REG_W_En <= 0; // Disable write
        @(posedge CLK); 
        assert (REG_R_Data1 == 32'h0000_0000) 
            else $error("Error: Violated register 0 specification, expected %h, got %h", 32'h0000_0000, $sampled(REG_R_Data1));

        @(posedge CLK); 

        // Assert that writing to extreme value register works correctly
        REG_W_Addr <= 5'h1F; // Write to x31
        REG_W_Data <= 32'h2A2A_2A2A;
        REG_W_En <= 1; 
        @(posedge CLK); 
        REG_R_Addr2 <= 5'h1F; // Set read to x31, use second read port
        REG_W_En <= 0; 
        @(posedge CLK);
        assert (REG_R_Data2 == 32'h2A2A_2A2A) 
            else $error("Error: Write did not execute correctly, expected %h, got %h", 32'h2A2A_2A2A, $sampled(REG_R_Data2));
        
        @(posedge CLK); 

        Reference[0] <= 32'h0000_0000; // Initialize x0 reference register

        // Write to all registers with random data, write to reference at the same time for comparison after
        for (int i = 1; i < 32; i++) begin
            REG_W_Addr <= i;
            REG_W_Data <= $urandom;
            REG_W_En <= 1;
            @(posedge CLK);
            Reference[i] <= REG_W_Data;
        end
        REG_W_En <= 0;

        // Read from all registers and compare to reference
        for (int i = 0; i < 31; i++) begin
            REG_R_Addr1 <= i;
            REG_R_Addr2 <= i+1;
            @(posedge CLK);
            assert (REG_R_Data1 == Reference[i]) 
                else $error("Error: Register %h did not read/write correctly, expected %h, got %h", i, Reference[i], $sampled(REG_R_Data1));
            assert (REG_R_Data2 == Reference[i+1]) 
                else $error("Error: Register %h did not read/write correctly, expected %h, got %h", i+1, Reference[i+1], $sampled(REG_R_Data2));
        end

        repeat (5) @ (posedge CLK); // Extra time for visual purposes
        $stop; 
    end
    
endmodule