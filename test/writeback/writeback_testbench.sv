//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Writeback Testbench                                                   
// Description: This is a testbench to ensure that the Writeback multiplexer selects the correct result to write to the register file.
// Author: Luke Shepherd                                                     
// Date Created: February 2025                                                                                                                                                                                                                                                      
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module writeback_testbench;
    logic CLK; // Wrap module with a clock to better represent the outside system
    logic [1:0] Result_Src_Sel;
    logic [31:0] Data_Out_Ext;
    logic [31:0] ALU_Out;
    logic [31:0] PC_Plus_4;
    logic [31:0] Result;

    writeback wb (
        .Result_Src_Sel_W(Result_Src_Sel),
        .Data_Out_Ext_W(Data_Out_Ext),
        .ALU_Out_W(ALU_Out),
        .PC_Plus_4_W(PC_Plus_4),
        .Result_W(Result)
    );

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        // Initialize signals
        Result_Src_Sel <= 2'h0;
        Data_Out_Ext <= 32'h0;
        ALU_Out <= 32'h0;
        PC_Plus_4 <= 32'h0;
        @(posedge CLK);

        // Test ALU result
        Result_Src_Sel <= RESULT_ALU;
        Data_Out_Ext <= 32'h0;
        ALU_Out <= 32'hFFFF_FFFF;
        PC_Plus_4 <= 32'h0;
        @(posedge CLK);
        assert (Result == 32'hFFFF_FFFF) else $error("Error: Incorrect result produced for ALU select, expected 0xFFFFFFFF, got 0x%h", $sampled(Result));

        // Test Memory Output result
        Result_Src_Sel <= RESULT_MEM;
        Data_Out_Ext <= 32'h1111_1111;
        ALU_Out <= 32'h0;
        PC_Plus_4 <= 32'h0;
        @(posedge CLK);
        assert (Result == 32'h1111_1111) else $error("Error: Incorrect result produced for ALU select, expected 0x11111111, got 0x%h", $sampled(Result));

        // Test PC + 4 result
        Result_Src_Sel <= RESULT_PC4;
        Data_Out_Ext <= 32'h0;
        ALU_Out <= 32'h0;
        PC_Plus_4 <= 32'h4444_4444;
        @(posedge CLK);
        assert (Result == 32'h4444_4444) else $error("Error: Incorrect result produced for ALU select, expected 0x44444444, got 0x%h", $sampled(Result));
        $stop;
    end
endmodule