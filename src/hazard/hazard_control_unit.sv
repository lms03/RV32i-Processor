//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Hazard Control Unit                                                   
// Description: Evaluates operands to produce pipeline control signals to enable forwarding, stalling and flushing mechanisms.
// Author: Luke Shepherd                                                     
// Date Modified: March 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module hazard_control_unit (
    /*========================*/
    //     Input Signals      //

    //     Load RAW Hazard    //
    input wire [4:0] RS1_D, RS2_D, RD_E,
    input wire [1:0] Result_Src_Sel_E, 

    //   Regular RAW Hazard   //
    input wire [4:0] RS1_E, RS2_E,       
    input wire [4:0] RD_M,
    input wire REG_W_En_M, 
    input wire [4:0] RD_W,
    input wire REG_W_En_W,

    //  Branch Misprediction  //
    input wire Branch_Taken_E, Predict_Taken_E,
    
    /*========================*/
    /*||||||||||||||||||||||||*/
    /*========================*/
    //     Output Signals     //

    //    Control Signals     //
    output logic [1:0] FWD_SrcA, FWD_SrcB,
    output logic Stall_En, Flush_D, Flush_E, PC_En
    
    /*========================*/
    );

    // Forwarding SrcA for RAW hazards
    always_comb begin
        if (RS1_E == RD_M && REG_W_En_M && RD_M != 5'b0)  
            FWD_SrcA = FWD_MEM;
        else if (RS1_E == RD_W && REG_W_En_W && RD_W != 5'b0)
            FWD_SrcA = FWD_WB;
        else
            FWD_SrcA = FWD_NONE;
    end

    // Forwarding SrcB for RAW hazards
    always_comb begin
        if (RS2_E == RD_M && REG_W_En_M && RD_M != 5'b0)  
            FWD_SrcB = FWD_MEM;
        else if (RS2_E == RD_W && REG_W_En_W && RD_W != 5'b0)
            FWD_SrcB = FWD_WB;
        else
            FWD_SrcB = FWD_NONE;
    end

    // Branch misprediction and load hazard handling
    always_comb begin
        // Flush the pipeline of misfetched instructions
        if (Branch_Taken_E != Predict_Taken_E) begin
            PC_En = 1'b1;
            Flush_E = 1'b1;
            Flush_D = 1'b1;
            Stall_En = 1'b0;
        end
        // Insert a bubble in the case of Load RAW hazard
        else if ((RS1_D == RD_E || RS2_D == RD_E) && Result_Src_Sel_E == RESULT_MEM) begin
            PC_En = 1'b0;
            Flush_D = 1'b0; // Don't flush just stall the decode stage
            Flush_E = 1'b1;
            Stall_En = 1'b1;
        end
        else begin
            PC_En = 1'b1;
            Flush_D = 1'b0;
            Flush_E = 1'b0;
            Stall_En = 1'b0;
        end
    end
endmodule