//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Fetch                                                   
// Description: Holds all fetch stage modules.
//              Program Counter: 
//                  Points to the next instruction to be executed.
//                  Uses synchronous reset.        
//              Instruction Memory:
//                  Holds the program for the processor to execute 
//                  and outputs the instruction pointed to by the PC.
//              Branch Predictor:
//                  Implements a 2-bit saturating counter to predict
//                  whether a branch will be taken or not.
// Author: Luke Shepherd                                                     
// Date Modified: March 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module fetch (
    input wire CLK, RST, PC_En,
    output wire [31:0] Instr_F, PC_F, PC_Plus_4_F
    );

    program_counter pc (
        .CLK(CLK),
        .RST(RST),
        .PC_En(PC_En),
        .PC_In(PC_Plus_4_F),
        .PC_Out(PC_F)
    );

    adder32 pc_adder (
        .A(PC_F),
        .B(32'h4),
        .OUT(PC_Plus_4_F)
    );

    instruction_memory imem (
        .PC_Addr(PC_F),
        .Instr(Instr_F)
    );

endmodule

module program_counter (
    input wire CLK, RST, PC_En,
    input wire [31:0] PC_In,
    output logic [31:0] PC_Out
    );

    always_ff @ (posedge CLK) begin // Synchronous reset
        if (RST)
            PC_Out <= 32'b0;
        else if (PC_En)             
            PC_Out <= PC_In;           
    end
endmodule

module instruction_memory (
    input wire [31:0] PC_Addr,
    output wire [31:0] Instr
    );

    logic [31:0] memory [0:255];

    initial begin
        $readmemh("src/program.hex", memory);
    end

    assign Instr = memory[PC_Addr[31:2]]; // Use word aligned addressing
endmodule

module branch_predictor (
    input wire Branch_Taken, Predict_Taken,
    output logic Predict_Out
    );
    
    logic [1:0] state;

    always_comb begin
        case (state)
            STRONGLY_UNTAKEN: 
                if (Predict_Taken == Branch_Taken) // If prediction correct
                    state = WEAKLY_UNTAKEN;
                else
                    state = STRONGLY_UNTAKEN;
            WEAKLY_UNTAKEN: // These two cases could use +- but this is more readable
                if (Predict_Taken == Branch_Taken) 
                    state = WEAKLY_TAKEN;
                else
                    state = STRONGLY_UNTAKEN;
            WEAKLY_TAKEN:
                if (Predict_Taken == Branch_Taken)
                    state = STRONGLY_TAKEN;
                else
                    state = WEAKLY_UNTAKEN;
            STRONGLY_TAKEN:
                if (Predict_Taken == Branch_Taken)
                    state = STRONGLY_TAKEN;
                else
                    state = WEAKLY_TAKEN;
            default:
                state = WEAKLY_TAKEN;   // Initialize/default to weakly taken
        endcase
    end

    assign Predict_Out = (state == STRONGLY_TAKEN) ? 1 : (state == WEAKLY_TAKEN) ? 1 : 0;
endmodule