//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Writeback                                                   
// Description: Holds the Writeback stage multiplexer.
// Author: Luke Shepherd
// Date Modified: March 2025                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

import definitions::*;

module writeback (
    /*========================*/
    //     Input Signals      //

    //   Control unit signal  //
    input wire [1:0] Result_Src_Sel_W,

    //      Data memory       //
    input wire [31:0] Data_Out_Ext_W,

    //       ALU output       //
    input wire [31:0] ALU_Out_W,

    //          PC            //
    input wire [31:0] PC_Plus_4_W,

    /*========================*/
    /*||||||||||||||||||||||||*/
    /*========================*/
    //     Output Signals     //

    output logic [31:0] Result_W

    /*========================*/
    );

    always_comb begin
        case (Result_Src_Sel_W)
            RESULT_ALU: Result_W = ALU_Out_W;
            RESULT_MEM: Result_W = Data_Out_Ext_W;
            RESULT_PC4: Result_W = PC_Plus_4_W;
            default: Result_W = 32'h0000_0000; 
        endcase
    end
endmodule