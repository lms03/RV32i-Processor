//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Data Memory Testbench                                                   
// Description: This is a testbench to ensure that the data memory stores and loads data correctly.
// Author: Luke Shepherd                                                     
// Date Modified: March 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module data_memory_testbench;
    logic CLK, MEM_W_En; 
    logic [2:0] MEM_Control;
    logic [11:0] RW_Addr;
    logic [31:0] W_Data;
    logic [31:0] Data_Out;
    
    unified_memory dmem (
        .CLK(CLK),
        .RST(1'b0),
        .Flush_D(1'b0),
        .Stall_En(1'b0),
        .MEM_W_En(MEM_W_En),
        .MEM_Control(MEM_Control),
        .RW_Addr(RW_Addr),
        .SrcB_Reg_M(W_Data),
        .R_Data(Data_Out),
        .PC_Addr(10'b0)
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
        W_Data <= 32'h1111_11FF; 
        @(posedge CLK); // Clock to set up inputs
        @(posedge CLK); // Clock again to store
        assert (dmem.memory.ram_block[0][7:0] == 8'hFF) else $error("Error: Unit did not store byte correctly, expected 0xFF, got 0x%h", $sampled(dmem.memory.ram_block[0][7:0]));

        
        // Test Store Halfword
        MEM_W_En <= 1;
        MEM_Control <= MEM_HALFWORD;
        RW_Addr <= 32'h0000_0002;
        W_Data <= 32'hF11F_F00F;
        @(posedge CLK);
        @(posedge CLK); 
        assert (dmem.memory.ram_block[0][31:16] == 16'hF00F) else $error("Error: Unit did not store halfword correctly, expected 0xF00F, got 0x%h", $sampled(dmem.memory.ram_block[0][31:16]));

        // Test Store Word
        MEM_W_En <= 1;
        MEM_Control <= MEM_WORD;
        RW_Addr <= 32'h0000_0004; 
        W_Data <= 32'hFBBF_FAAF; 
        @(posedge CLK);
        @(posedge CLK); 
        assert (dmem.memory.ram_block[1] == 32'hFBBF_FAAF) else $error("Error: Unit did not store word correctly, expected 0xFBBFFAAF, got 0x%h", $sampled(dmem.memory.ram_block[1]));

        // Test Load Byte
        MEM_W_En <= 0;
        MEM_Control <= MEM_BYTE;
        RW_Addr <= 32'h0000_0000;
        @(posedge CLK); // Clock to set up inputs
        @(posedge CLK); // Clock again to load
        assert (Data_Out == 32'hFFFF_FFFF) else $error("Error: Unit did not load signed byte correctly, expected 0xFFFFFFFF, got 0x%h", $sampled(Data_Out));

        // Test Load Byte Unsigned
        MEM_W_En <= 0;
        MEM_Control <= MEM_BYTE_UNSIGNED;
        RW_Addr <= 32'h0000_0000;
        @(posedge CLK);
        @(posedge CLK);
        assert (Data_Out == 32'h0000_00FF) else $error("Error: Unit did not load unsigned byte correctly, expected 0x000000FF, got 0x%h", $sampled(Data_Out));

        // Test Load Halfword
        MEM_W_En <= 0;
        MEM_Control <= MEM_HALFWORD;
        RW_Addr <= 32'h0000_0002;
        @(posedge CLK);
        @(posedge CLK);
        assert (Data_Out == 32'hFFFF_F00F) else $error("Error: Unit did not load signed halfword correctly, expected 0xFFFFF00F, got 0x%h", $sampled(Data_Out));

        // Test Load Halfword Unsigned
        MEM_W_En <= 0;
        MEM_Control <= MEM_HALFWORD_UNSIGNED;
        RW_Addr <= 32'h0000_0002;
        @(posedge CLK);
        @(posedge CLK);
        assert (Data_Out == 32'h0000_F00F) else $error("Error: Unit did not load unsigned halfword correctly, expected 0x0000F00F, got 0x%h", $sampled(Data_Out));

        // Test Load Word
        MEM_W_En <= 0;
        MEM_Control <= MEM_WORD;
        RW_Addr <= 32'h0000_0004;
        @(posedge CLK);
        @(posedge CLK);
        assert (Data_Out == 32'hFBBF_FAAF) else $error("Error: Unit did not load word correctly, expected 0xFBBFFAAF, got 0x%h", $sampled(Data_Out));
        

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
            assert (Data_Out == i) else $error("Error: Unit did not store and load correctly, expected 0x%h, got 0x%h", i, $sampled(Data_Out)); 
        end
    end
    endtask

endmodule