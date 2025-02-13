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
    logic [31:0] ALU_Out, REG_R_Data2;
    logic [31:0] Data_Out;

    data_memory dmem (
        .CLK(CLK),
        .MEM_W_En(MEM_W_En),
        .MEM_Control(MEM_Control),
        .ALU_Out(ALU_Out),
        .REG_R_Data2(REG_R_Data2),
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
        ALU_Out <= 32'h0000_0000;
        REG_R_Data2 <= 32'hFFFF_FFFF; 
        @(posedge CLK); // Clock to set up inputs
        @(posedge CLK); // Clock again to store
        assert (dmem.memory[0] ==? 32'hxxxx_xxFF) else $error("Error: Unit did not store byte correctly, expected 0xXXXXXXFF, got %h", $sampled(dmem.memory[0]));

        // Test Store Halfword
        MEM_W_En <= 1;
        MEM_Control <= MEM_HALFWORD;
        ALU_Out <= 32'h0000_0001;
        REG_R_Data2 <= 32'hF00F_F00F;
        @(posedge CLK);
        @(posedge CLK);
        assert (dmem.memory[1] ==? 32'hxxxx_F00F) else $error("Error: Unit did not store halfword correctly, expected 0xXXXXF00F, got %h", $sampled(dmem.memory[1]));

        // Test Store Word
        MEM_W_En <= 1;
        MEM_Control <= MEM_WORD;
        ALU_Out <= 32'h0000_0002; 
        REG_R_Data2 <= 32'hFAAF_FAAF; 
        @(posedge CLK);
        @(posedge CLK);
        assert (dmem.memory[2] == 32'hFAAF_FAAF) else $error("Error: Unit did not store word correctly, expected 0xFAAFFAAF, got %h", $sampled(dmem.memory[2]));

        // Test Load Byte
        MEM_W_En <= 0;
        MEM_Control <= MEM_BYTE;
        ALU_Out <= 32'h0000_0000;
        @(posedge CLK);
        assert (Data_Out == 32'hFFFF_FFFF) else $error("Error: Unit did not load signed byte correctly, expected 0xFFFFFFFF, got %h", $sampled(Data_Out));

        // Test Load Byte Unsigned
        MEM_W_En <= 0;
        MEM_Control <= MEM_BYTE_UNSIGNED;
        ALU_Out <= 32'h0000_0000;
        @(posedge CLK);
        assert (Data_Out == 32'h0000_00FF) else $error("Error: Unit did not load unsigned byte correctly, expected 0x000000FF, got %h", $sampled(Data_Out));

        // Test Load Halfword
        MEM_W_En <= 0;
        MEM_Control <= MEM_HALFWORD;
        ALU_Out <= 32'h0000_0001;
        @(posedge CLK);
        assert (Data_Out == 32'hFFFF_F00F) else $error("Error: Unit did not load signed halfword correctly, expected 0xFFFFF00F, got %h", $sampled(Data_Out));

        // Test Load Halfword Unsigned
        MEM_W_En <= 0;
        MEM_Control <= MEM_HALFWORD_UNSIGNED;
        ALU_Out <= 32'h0000_0001;
        @(posedge CLK);
        assert (Data_Out == 32'h0000_F00F) else $error("Error: Unit did not load unsigned halfword correctly, expected 0x0000F00F, got %h", $sampled(Data_Out));

        // Test Load Word
        MEM_W_En <= 0;
        MEM_Control <= MEM_WORD;
        ALU_Out <= 32'h0000_0002;
        @(posedge CLK);
        assert (Data_Out == 32'hFAAF_FAAF) else $error("Error: Unit did not load unsigned halfword correctly, expected 0xFAAFFAAF, got %h", $sampled(Data_Out));
        
        operate(); // Test storing then reading from every address
        $stop; 
    end

    task operate(); begin
        for (int i = 0; i < 256; i++) begin
            MEM_W_En <= 1;
            MEM_Control <= MEM_WORD;
            ALU_Out <= i;
            REG_R_Data2 <= i;
            @(posedge CLK);
        end
        for (int i = 0; i < 256; i++) begin
            MEM_W_En <= 0;
            MEM_Control <= MEM_WORD;
            ALU_Out <= i;
            @(posedge CLK);
            assert (Data_Out == i) else $error("Error: Unit did not store and load correctly, expected %d, got %h", i, $sampled(Data_Out)); 
        end
    end
    endtask

endmodule