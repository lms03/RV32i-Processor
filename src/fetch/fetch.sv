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
    input wire Predict_Taken_E, Branch_Taken_E, Valid_E,
    input wire [31:0] PC_Target_E, PC_Plus_4_E, PC_E,
    output wire [31:0] PC_F, PC_Plus_4_F, // Instr_F goes directly to decode since it is read into a register.
    output wire Predict_Taken_F, Valid_F
    );

    wire [31:0] PC_In, PC_Next, PC_Predict, PC_Prediction;
    wire Predict_Out, PC_Overwrite_Sel, PC_Sel;

    assign PC_Sel = !Predict_Taken_E && Branch_Taken_E; // If we didn't predict and we should have taken we need to overwrite
    assign Predict_Taken_F = Predict_Out && Valid_F; // Only predict if we have a corresponding branch target prediction
    assign PC_Overwrite_Sel = Predict_Taken_E && !Branch_Taken_E; // Overwrite if we predicted it to be taken but it shouldn't have been

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

    branch_predictor bp (
        .CLK(CLK),
        .RST(RST),
        .Branch_Taken(Branch_Taken_E),
        .Predict_Taken(Predict_Taken_E),
        .Valid(Valid_E),
        .Predict_Out(Predict_Out)
    );

    branch_target_buffer btb (
        .CLK(CLK),
        .RST(RST),
        .PC_Target(PC_Target_E),
        .PC_F(PC_F),
        .PC_E(PC_E),
        .Branch_Taken(Branch_Taken_E),
        .Valid(Valid_F),
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
        .SEL(PC_Sel),
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
            PC_Out <= {PC_In[31:2], 2'b0}; // Force word alignment
    end
endmodule

module branch_predictor (
    input wire CLK, RST, Branch_Taken, Predict_Taken, Valid,
    output logic Predict_Out
    );
    
    logic [1:0] current_state, next_state;

    always_ff @ (posedge CLK) begin
        if (RST) current_state <= WEAKLY_TAKEN; // Initialize/default to weakly taken
        else current_state <= next_state;
    end

    always_comb begin
        if (Valid) begin
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
        else next_state = current_state; // Don't change state for invalid (non-branch) instructions
    end

    assign Predict_Out = current_state[1]; // MSB of state indicated taken or not
endmodule

module branch_target_buffer (
    input wire CLK, RST,
    input wire [31:0] PC_Target, PC_E, PC_F,
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
            target[PC_E[4:0]] <= PC_Target; // Index with the lower bits of PC
            pc[PC_E[4:0]] <= PC_E;          // Store depends on PC of execute stage
            valid[PC_E[4:0]] <= 1;
        end
    end

    // Asynchronous read
    always_comb begin
        if(PC_F == pc[PC_F[4:0]]) begin // Check if present in BTB
            Valid = valid[PC_F[4:0]];  // Output depends on PC of fetch stage
            PC_Prediction = target[PC_F[4:0]];
        end
        else begin
            Valid = 1'b0; // If not present in BTB
            PC_Prediction = 32'b0;
        end
    end
endmodule