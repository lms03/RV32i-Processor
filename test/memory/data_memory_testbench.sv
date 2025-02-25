//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Data Memory Testbench                                                   
// Description: This is a testbench to ensure that the data memory stores and loads data correctly.
// Author: Luke Shepherd                                                     
// Date Modified: February 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module data_memory_testbench;
    logic CLK, MEM_W_En; 
    logic [2:0] MEM_Control;
    logic [31:0] RW_Addr, W_Data;
    logic [31:0] Data_Out;

    data_memory dmem (
        .CLK(CLK),
        .MEM_W_En(MEM_W_En),
        .MEM_Control(MEM_Control),
        .RW_Addr(RW_Addr),
        .W_Data(W_Data),
        .Data_Out(Data_Out)
    );

    initial CLK <= 1; // Initialize the clock
    always #(CLOCK_PERIOD / 2) CLK <= ~CLK; // Generate the clock

    initial begin
        MEM_W_En <= 0;
        @(posedge CLK);

        // Test Store Byte
        MEM_W_En <= 1;
        MEM_Control <= MEM_BYTE;
        RW_Addr <= 32'h0000_0000;
        W_Data <= 32'hFFFF_FFFF; 
        @(posedge CLK); // Clock to set up inputs
        @(posedge CLK); // Clock again to store
        assert (dmem.memory[0] == 8'hFF) else $error("Error: Unit did not store byte correctly, expected 0xFF, got %h", $sampled(dmem.memory[0]));

        // Test Store Halfword
        MEM_W_En <= 1;
        MEM_Control <= MEM_HALFWORD;
        RW_Addr <= 32'h0000_0002;
        W_Data <= 32'hF00F_F00F;
        @(posedge CLK);
        @(posedge CLK);
        assert (dmem.memory[3] == 8'hF0 && dmem.memory[2] == 8'h0F) else $error("Error: Unit did not store halfword correctly, expected 0xF0 0x0F, got %h %h", $sampled(dmem.memory[3]), $sampled(dmem.memory[2]));

        // Test Store Word
        MEM_W_En <= 1;
        MEM_Control <= MEM_WORD;
        RW_Addr <= 32'h0000_0004; 
        W_Data <= 32'hFAAF_FAAF; 
        @(posedge CLK);
        @(posedge CLK);
        assert (dmem.memory[7] == 8'hFA && dmem.memory[6] == 8'hAF && dmem.memory[5] == 8'hFA && dmem.memory[4] == 8'hAF) else $error("Error: Unit did not store word correctly, expected 0xFAAFFAAF, got %h %h %h %h", $sampled(dmem.memory[7]), $sampled(dmem.memory[6]), $sampled(dmem.memory[5]), $sampled(dmem.memory[4]));

        // Test Load Byte
        MEM_W_En <= 0;
        MEM_Control <= MEM_BYTE;
        RW_Addr <= 32'h0000_0000;
        @(posedge CLK); // Clock to set up inputs
        @(posedge CLK); // Clock again to load
        assert (Data_Out == 32'hFFFF_FFFF) else $error("Error: Unit did not load signed byte correctly, expected 0xFFFFFFFF, got %h", $sampled(Data_Out));

        // Test Load Byte Unsigned
        MEM_W_En <= 0;
        MEM_Control <= MEM_BYTE_UNSIGNED;
        RW_Addr <= 32'h0000_0000;
        @(posedge CLK);
        @(posedge CLK);
        assert (Data_Out == 32'h0000_00FF) else $error("Error: Unit did not load unsigned byte correctly, expected 0x000000FF, got %h", $sampled(Data_Out));

        // Test Load Halfword
        MEM_W_En <= 0;
        MEM_Control <= MEM_HALFWORD;
        RW_Addr <= 32'h0000_0002;
        @(posedge CLK);
        @(posedge CLK);
        assert (Data_Out == 32'hFFFF_F00F) else $error("Error: Unit did not load signed halfword correctly, expected 0xFFFFF00F, got %h", $sampled(Data_Out));

        // Test Load Halfword Unsigned
        MEM_W_En <= 0;
        MEM_Control <= MEM_HALFWORD_UNSIGNED;
        RW_Addr <= 32'h0000_0002;
        @(posedge CLK);
        @(posedge CLK);
        assert (Data_Out == 32'h0000_F00F) else $error("Error: Unit did not load unsigned halfword correctly, expected 0x0000F00F, got %h", $sampled(Data_Out));

        // Test Load Word
        MEM_W_En <= 0;
        MEM_Control <= MEM_WORD;
        RW_Addr <= 32'h0000_0004;
        @(posedge CLK);
        @(posedge CLK);
        assert (Data_Out == 32'hFAAF_FAAF) else $error("Error: Unit did not load unsigned halfword correctly, expected 0xFAAFFAAF, got %h", $sampled(Data_Out));
        
        operate(); // Test storing then reading from every address
        $stop; 
    end

    task operate(); begin
        for (int i = 0; i < 256; i += 4) begin
            MEM_W_En <= 1;
            MEM_Control <= MEM_WORD;
            RW_Addr <= i; 
            W_Data <= i;
            @(posedge CLK);
        end
        for (int i = 0; i < 256; i += 4) begin
            MEM_W_En <= 0;
            MEM_Control <= MEM_WORD;
            RW_Addr <= i; 
            @(posedge CLK); // Set up 
            @(posedge CLK); // Clock to allow read to happen
            assert (Data_Out == i) else $error("Error: Unit did not store and load correctly, expected %d, got %h", i, $sampled(Data_Out)); 
        end
    end
    endtask

endmodule