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
//              Branch Target Buffer:
//                  Stores the target and pc addresses of a branch instruction
//                  and a valid bit.
// Author: Luke Shepherd                                                     
// Date Modified: March 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module fetch (
    input wire CLK, RST, PC_En,
    input wire Predict_Taken_E, Branch_Taken_E,
    input wire [31:0] PC_Target_E, PC_Plus_4_E,
    output wire [31:0] Instr_F, PC_F, PC_Plus_4_F,
    output wire Predict_Taken_F
    );

    wire [31:0] PC_In, PC_Next, PC_Predict, PC_Prediction;
    wire Predict_Out, PC_Overwrite_Sel, Valid;

    assign Predict_Taken_F = Predict_Out && Valid; // Only predict if we have a corresponding branch target prediction
    assign PC_Overwrite_Sel = Predict_Taken_F && !Branch_Taken_E; // Overwrite if we predicted it to be taken but it shouldn't have been

    program_counter pc (
        .CLK(CLK),
        .RST(RST),
        .PC_En(PC_En),
        .PC_In(PC_In),
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

    branch_predictor bp (
        .CLK(CLK),
        .RST(RST),
        .Branch_Taken(Branch_Taken_E),
        .Predict_Taken(Predict_Taken_E),
        .Predict_Out(Predict_Out)
    );

    branch_target_buffer btb (
        .CLK(CLK),
        .RST(RST),
        .PC_Target(PC_Target_E),
        .PC(PC_F),
        .Branch_Taken(Branch_Taken_E),
        .Valid(Valid),
        .PC_Prediction(PC_Prediction)
    );

    // If we mispredict we can overwrite with the PC+4 from the execute phase
    mux2_1 mux2_1_overwrite (
        .SEL(PC_Overwrite_Sel),
        .A(PC_Next),
        .B(PC_Plus_4_E),
        .OUT(PC_In)
    );

    // If we predict a branch taken we use the predicted PC from the BTB
    mux2_1 mux2_1_pc_predict (
        .SEL(Predict_Taken_F),
        .A(PC_Plus_4_F),
        .B(PC_Prediction),
        .OUT(PC_Predict)
    );

    // If a branch evaluated to taken later we use the calculated target PC otherwise the outcome from the previous MUX
    mux2_1 mux2_1_pc_branch (
        .SEL(Branch_Taken_E),
        .A(PC_Predict),
        .B(PC_Target_E),
        .OUT(PC_Next)
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

    assign Instr = memory[PC_Addr[9:2]]; // Use word aligned addressing
endmodule

module branch_predictor (
    input wire CLK, RST, Branch_Taken, Predict_Taken,
    output logic Predict_Out
    );
    
    logic [1:0] current_state, next_state;

    always_ff @ (posedge CLK) begin
        if(RST)
            current_state <= WEAKLY_TAKEN; // Initialize/default to weakly taken
        else
            current_state <= next_state;
    end

    always_comb begin
        case (current_state)
            STRONGLY_UNTAKEN: 
                if (Predict_Taken == Branch_Taken) // If prediction correct
                    next_state = WEAKLY_UNTAKEN;
                else
                    next_state = STRONGLY_UNTAKEN;
            WEAKLY_UNTAKEN: // These two cases could use +- but this is more readable
                if (Predict_Taken == Branch_Taken) 
                    next_state = WEAKLY_TAKEN;
                else
                    next_state = STRONGLY_UNTAKEN;
            WEAKLY_TAKEN:
                if (Predict_Taken == Branch_Taken)
                    next_state = STRONGLY_TAKEN;
                else
                    next_state = WEAKLY_UNTAKEN;
            STRONGLY_TAKEN:
                if (Predict_Taken == Branch_Taken)
                    next_state = STRONGLY_TAKEN;
                else
                    next_state = WEAKLY_TAKEN;
            default:
                next_state = WEAKLY_TAKEN;   
        endcase
    end

    assign Predict_Out = (current_state == STRONGLY_TAKEN) || (current_state == WEAKLY_TAKEN);
endmodule

module branch_target_buffer (
    input wire CLK, RST,
    input wire [31:0] PC_Target, PC,
    input wire Branch_Taken,
    output logic Valid,
    output logic [31:0] PC_Prediction
    );

    // 32 entry BTB with 32+32+1 bits per entry. Should become 2080bits of distributed RAM since we need asynch read.
    logic [31:0] target [0:31]; 
    logic [31:0] pc [0:31];
    logic valid [0:31];

    // Synchronous write/update/reset
    always_ff @ (posedge CLK) begin
        // Ensure valid bits are 0 on reset
        if(RST) begin 
            for (int i = 0; i < 32; i++) begin
                valid[i] <= 1'b0;
            end
        end
        else
        if (Branch_Taken) begin           // Only store taken branches
            target[PC[4:0]] <= PC_Target; // Index with the lower bits of PC
            pc[PC[4:0]] <= PC;
            valid[PC[4:0]] <= 1;
        end
    end

    // Asynchronous read
    always_comb begin
        Valid = valid[PC[4:0]];
        PC_Prediction = target[PC[4:0]];
    end
endmodule