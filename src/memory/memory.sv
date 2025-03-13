//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Memory                                                   
// Description: Holds all Memory stage modules.
//              Unified Memory:
//                  Acts as a wrapper to the below module in order to have a simple external interface.
//              bytewrite_tdp_ram_rf: 
//                  A true-dual-port BRAM template from AMD to represent the memory for the processor, 
//                  load/store uses port A and instruction fetch uses port B.
// Author: Luke Shepherd
// Date Modified: March 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module memory (
    /*========================*/
    //     Input Signals      //

    // Global Control Signals //
    input wire CLK, RST,

    //  Control unit signals  //
    input wire MEM_W_En_M,
    input wire [2:0] MEM_Control_M,

    //     Register data      //
    input wire [31:0] SrcB_Reg_M,

    //       ALU output       //
    input wire [11:0] ALU_Out_M,

    //   PC from fetch stage  //
    input wire [11:2] PC_F,

    // Hazard control signals //
    input wire Flush_D, Stall_En,

    /*========================*/
    /*||||||||||||||||||||||||*/
    /*========================*/
    //     Output Signals     //
    
    //       Data reads       //
    output wire [31:0] Data_Out_Ext_M,

    //   Instruction fetches  //
    output logic [31:0] Instr_D

    /*========================*/
    );

    unified_memory unified_memory (
        .CLK(CLK),
        .RST(RST),
        .MEM_W_En(MEM_W_En_M),
        .MEM_Control(MEM_Control_M),
        .RW_Addr(ALU_Out_M),
        .PC_Addr(PC_F),
        .SrcB_Reg_M(SrcB_Reg_M),
        .Instr(Instr_D),
        .R_Data(Data_Out_Ext_M),
        .Flush_D(Flush_D),
        .Stall_En(Stall_En)
    );
endmodule

module unified_memory (
    input wire CLK, RST, Flush_D, Stall_En, MEM_W_En,
    input wire [2:0] MEM_Control,
    input wire [11:0] RW_Addr, 
    input wire [31:0] SrcB_Reg_M,
    input wire [11:2] PC_Addr,
    output wire [31:0] Instr,
    output logic [31:0] R_Data
    );

    wire MEM_W_En0, MEM_W_En1, MEM_W_En2, MEM_W_En3;   // Write enables for each memory
    wire [3:0] W_En;                               // Combined write enables to pass to memory module
    wire [31:0] Data_Out;
    wire [31:0] Instr_Temp; 
    wire [9:0] RW_Word_Addr;
    logic [1:0] RW_Reg; // Hold the RW address for data selection which must be delayed by one to be after the read (Only need bottom 2 bits)
    logic [2:0] MEM_Control_Reg; // Hold the MEM_Control signal for data selection which must occur after the read (1cycle)
    logic [31:0] Instr_Reg; // Hold the instruction in case of stall
    logic Flush_Reg, Stall_Reg, RST_Reg; // Delay signals 
    logic [31:0] W_Data; // Data to write to memory

    assign MEM_W_En0 = MEM_W_En && ((MEM_Control == MEM_BYTE && RW_Addr[1:0] == 2'b00) || 
                                    (MEM_Control == MEM_HALFWORD && RW_Addr[1] == 1'b0) || 
                                    (MEM_Control == MEM_WORD));
    assign MEM_W_En1 = MEM_W_En && ((MEM_Control == MEM_BYTE && RW_Addr[1:0] == 2'b01) || 
                                    (MEM_Control == MEM_HALFWORD && RW_Addr[1] == 1'b0) || 
                                    (MEM_Control == MEM_WORD));
    assign MEM_W_En2 = MEM_W_En && ((MEM_Control == MEM_BYTE && RW_Addr[1:0] == 2'b10) || 
                                    (MEM_Control == MEM_HALFWORD && RW_Addr[1] == 1'b1) || 
                                    (MEM_Control == MEM_WORD));
    assign MEM_W_En3 = MEM_W_En && ((MEM_Control == MEM_BYTE && RW_Addr[1:0] == 2'b11) || 
                                    (MEM_Control == MEM_HALFWORD && RW_Addr[1] == 1'b1) || 
                                    (MEM_Control == MEM_WORD));

    assign W_En = {MEM_W_En3, MEM_W_En2, MEM_W_En1, MEM_W_En0};

    always_ff @(posedge CLK) begin
        if (RST) begin
            Instr_Reg <= 32'b0;
        end else if (Flush_D) begin
            Instr_Reg <= 32'h0000_0013;
        end else begin
            Instr_Reg <= Instr_Temp;
        end
        Stall_Reg <= Stall_En;
        Flush_Reg <= Flush_D;
        RST_Reg <= RST;
        RW_Reg <= RW_Addr[1:0];
        MEM_Control_Reg <= MEM_Control;
    end

    assign Instr = (Stall_Reg || Flush_Reg || RST_Reg) ? Instr_Reg : Instr_Temp;

    assign RW_Word_Addr[9:0] = RW_Addr >> 2;

    bytewrite_tdp_ram_rf memory (
        .clkA(CLK),                     // Use the same clock for both ports but keep the template untouched.
        .enaA(1'b1),                    // Always enabled since the design has no mechanism for seperate port enables
        .weA(W_En),
        .addrA(RW_Word_Addr),
        .dinA(W_Data),
        .doutA(Data_Out),               // Data operation output

        .clkB(CLK),
        .enaB(1'b1),
        .weB(4'b0000),                  // Don't write with this port since only dual read is needed, theres probably a better way to do it.
        .addrB(PC_Addr),                // PC for fetch address 
        .dinB(W_Data),                  // Not really used but kept for the template structure, won't be enabled anyway
        .doutB(Instr_Temp)              // Instruction fetch
    );

    always_comb begin // Move data to correct position for write
        case (MEM_Control) // Use current cycle version of this signal unlike below 
            MEM_BYTE: 
                case (RW_Addr[1:0])
                    2'b00: W_Data = SrcB_Reg_M; 
                    2'b01: W_Data = {16'b0, SrcB_Reg_M[7:0], 8'b0};
                    2'b10: W_Data = {8'b0, SrcB_Reg_M[7:0], 16'b0};
                    default: W_Data = {SrcB_Reg_M[7:0], 24'b0};
                endcase
            MEM_HALFWORD: 
                case (RW_Addr[1])
                    1'b0: W_Data = SrcB_Reg_M;
                    default: W_Data = {SrcB_Reg_M[15:0], 16'b0};
                endcase
            MEM_WORD: W_Data = SrcB_Reg_M; // Don't need to alter word
            default: W_Data = 32'b0;
        endcase
    end

    always_comb begin
        case (MEM_Control_Reg)
            MEM_BYTE: 
                case (RW_Reg[1:0])
                    2'b00: R_Data = {{24{Data_Out[7]}}, Data_Out[7:0]};
                    2'b01: R_Data = {{24{Data_Out[15]}}, Data_Out[15:8]};
                    2'b10: R_Data = {{24{Data_Out[23]}}, Data_Out[23:16]};
                    default: R_Data = {{24{Data_Out[31]}}, Data_Out[31:24]};
                endcase
            MEM_BYTE_UNSIGNED: 
                case (RW_Reg[1:0])
                    2'b00: R_Data = {24'b0, Data_Out[7:0]};
                    2'b01: R_Data = {24'b0, Data_Out[15:8]};
                    2'b10: R_Data = {24'b0, Data_Out[23:16]};
                    default: R_Data = {24'b0, Data_Out[31:24]};
                endcase
            MEM_HALFWORD:
                case (RW_Reg[1])
                    1'b0: R_Data = {{16{Data_Out[15]}}, Data_Out[15:8], Data_Out[7:0]};
                    default: R_Data = {{16{Data_Out[31]}}, Data_Out[31:24], Data_Out[23:16]};
                endcase
            MEM_HALFWORD_UNSIGNED: 
                case (RW_Reg[1])
                    1'b0: R_Data = {16'b0, Data_Out[15:8], Data_Out[7:0]};
                    default: R_Data = {16'b0, Data_Out[31:24], Data_Out[23:16]};
                endcase
            MEM_WORD: R_Data = Data_Out; // Kept for clarity
            default: R_Data = 32'b0;
        endcase
    end
endmodule

module bytewrite_tdp_ram_rf // True-Dual-Port BRAM with Byte-wide Write Enable (AMD Template)
    #(
    //--------------------------------------------------------------------------
    parameter NUM_COL = 4,
    parameter COL_WIDTH = 8,
    parameter ADDR_WIDTH = 10,
    // Addr Width in bits : 2^ADDR_WIDTH = RAM Depth
    parameter DATA_WIDTH = NUM_COL*COL_WIDTH // Data Width in bits
    //----------------------------------------------------------------------
    ) (
    input clkA,
    input enaA,
    input [NUM_COL-1:0] weA,
    input [ADDR_WIDTH-1:0] addrA,
    input [DATA_WIDTH-1:0] dinA,
    output reg [DATA_WIDTH-1:0] doutA,

    input clkB,
    input enaB,
    input [NUM_COL-1:0] weB,
    input [ADDR_WIDTH-1:0] addrB,
    input [DATA_WIDTH-1:0] dinB,
    output reg [DATA_WIDTH-1:0] doutB
    );

    // Core Memory
    reg [DATA_WIDTH-1:0] ram_block [(2**ADDR_WIDTH)-1:0];

    initial begin // Note from AMD: The external file initializing the RAM needs to be in bit vector form. External files in integer or hex format do not work.
        $readmemh("/home/s53512ls/git/RV32i-Processor/src/test.hex",ram_block);
    end

    integer i;
    // Port-A Operation
    always @ (posedge clkA) begin
        if(enaA) begin
            for(i=0;i<NUM_COL;i=i+1) begin
                if(weA[i]) begin
                    ram_block[addrA][i*COL_WIDTH +: COL_WIDTH] <= dinA[i*COL_WIDTH +: COL_WIDTH];
                end
            end
        doutA <= ram_block[addrA];
        end
    end

    // Port-B Operation:
    always @ (posedge clkB) begin
        if(enaB) begin
            for(i=0;i<NUM_COL;i=i+1) begin
                if(weB[i]) begin
                    ram_block[addrB][i*COL_WIDTH +: COL_WIDTH] <= dinB[i*COL_WIDTH +: COL_WIDTH];
                end
            end
        doutB <= ram_block[addrB];
        end
    end
endmodule 