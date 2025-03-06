//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Instruction Memory Testbench                                                   
// Description: This is a testbench to ensure that the instruction memory loads and fetches instructions correctly.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module instruction_memory_testbench;
    logic CLK, RST, Flush, Stall, MEM_W_En; 
    logic [2:0] MEM_Control;
    logic [31:0] RW_Addr, W_Data;
    logic [31:0] PC_Addr, Instr;
    logic [31:0] Data_Out;

    unified_memory imem (
        .CLK(CLK),
        .RST(RST),
        .Flush_D(Flush),
        .Stall_En(Stall),
        .PC_Addr(PC_Addr),
        .Instr(Instr),
        .R_Data(Data_Out),
        .MEM_W_En(MEM_W_En),
        .MEM_Control(MEM_Control),
        .RW_Addr(RW_Addr),
        .W_Data(W_Data)
    );

    logic [31:0] Reference [0:1023]; // Memory to compare against

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        $readmemh("src/test.hex", Reference); // Load the file to check with
        Stall <= 0;
        Flush <= 0;
        RST <= 0; 
        @(posedge CLK);
        PC_Addr <= 0;  // Initialize PC

        repeat (10) @ (posedge CLK); // Run some time 
        Flush <= 1; // Flush the instruction memory
        @(posedge CLK);
        Flush <= 0; // Unflush the instruction memory
        repeat (10) @ (posedge CLK); // Run some more time
        Stall <= 1; // Stall the instruction memory
        @(posedge CLK);
        Stall <= 0; // Unstall the instruction memory
        repeat (10) @ (posedge CLK); // Run some time to allow for all instructions to be read
        $stop; 
    end

    always @ (posedge CLK) begin
        if(!Stall) begin
            PC_Addr <= PC_Addr + 4; // Simulate the PC incrementing normally
        end
    end

    assertInstrCorrect: assert property (@(posedge CLK) (!RST && !Flush) |-> ##1 Instr === Reference[$past(PC_Addr)])
            else $error("Error: Mismatch at address %h: got %h, expected %h", $sampled($past(PC_Addr)), $sampled(Instr), $sampled(Reference[$past(PC_Addr)]));
    
    assertStall: assert property (@(posedge CLK) Stall |-> Instr === 32'h0000_0013)
            else $error("Error: Instruction should be blanked during a stall, got %h, expected 0x00000013", $sampled(Instr));

    assertFlush: assert property (@(posedge CLK) Flush |-> Instr === 32'h0000_0013)
            else $error("Error: Instruction should have been flushed, got %h, expected 0x00000013", $sampled(Instr));
endmodule