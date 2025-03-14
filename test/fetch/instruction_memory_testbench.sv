//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Instruction Memory Testbench                                                   
// Description: This is a testbench to ensure that the instruction memory loads and fetches instructions correctly.
// Author: Luke Shepherd                                                     
// Date Modified: March 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module instruction_memory_testbench;
    logic CLK, RST, Flush, Stall, MEM_W_En; 
    logic [2:0] MEM_Control;
    logic [31:0] RW_Addr, W_Data;
    logic [31:0] PC_F, PC_D, Instr;
    logic [31:0] Data_Out;

    unified_memory imem (
        .CLK(CLK),
        .RST(RST),
        .Flush_D(Flush),
        .Stall_En(Stall),
        .PC_Addr(PC_F),
        .Instr(Instr),
        .R_Data(Data_Out),
        .MEM_W_En(MEM_W_En),
        .MEM_Control(MEM_Control),
        .RW_Addr(RW_Addr),
        .W_Data(W_Data)
    );

    logic [31:0] Reference [1023:0]; // Memory to compare against

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        $readmemh("/home/s53512ls/git/RV32i-Processor/src/test.hex", Reference); // Load the file to check with
        Stall <= 0;
        Flush <= 0;
        RST <= 0; 
        @(posedge CLK);
        PC_F <= 0;  // Initialize PC
        @(posedge CLK);
        PC_D <= 0; // Initialize PC_D with delay

        repeat (10) @ (posedge CLK); // Run some time 
        Flush <= 1; // Test flush (should be like flushing the IF/ID register since the output of IMEM is Instr_D is essentially the output of IF/ID)
        @(posedge CLK);
        Flush <= 0; 
        repeat (10) @ (posedge CLK); // Run some more time
        Stall <= 1; // Test stall (like stalling IF/ID)
        @(posedge CLK);
        Stall <= 0; 
        repeat (10) @ (posedge CLK); // Run some more more time
        RST <= 1; // Test reset (like resetting IF/ID)
        @(posedge CLK);
        RST <= 0; 
        repeat (10) @ (posedge CLK); // Run some time to allow for all instructions to be read
        $stop; 
    end

    always @ (posedge CLK) begin
        if(!Stall && !Flush) begin
            PC_F <= PC_F + 4; // Simulate the PC incrementing normally
            PC_D <= PC_D + 4; // Simulate the PC being passed to the decode stage
        end
    end

    assertInstrCorrect: assert property (@(posedge CLK) (!Stall && !RST && !Flush) |-> ##1 Instr === Reference[$past(PC_F)])
            else $error("Error: Mismatch at address %h: got %h, expected %h", $sampled($past(PC_F)), $sampled(Instr), $sampled(Reference[$past(PC_F)]));
    
    assertStall: assert property (@(posedge CLK) (Stall && !Flush && !RST) |-> ##1 (Instr == $past(Instr)))
            else $error("Error: Instruction should be unchanged during a stall, got %h, expected %h", $sampled(Instr), $sampled($past(Instr)));

    assertFlush: assert property (@(posedge CLK) Flush |-> ##1 Instr === 32'h0000_0013)
            else $error("Error: Instruction should have been flushed, got %h, expected 0x00000013", $sampled(Instr));

    assertReset: assert property (@(posedge CLK) RST |-> ##1 (Instr == 32'h0000_0000))
            else $error("Error: Instruction should have been reset, got %h, expected 0x00000000", $sampled(Instr));
endmodule