//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// Module: Program Counter                                                      
// Description: Points to the next instruction to be executed.
//              Uses synchronous reset.         
// Author: Luke Shepherd                                                     
// Date Created: November 2024                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

module program_counter (
    input wire CLK, RST, PC_En,
    input wire [31:0] PC_In,
    output reg [31:0] PC_Out
    );

    always @ (posedge CLK) begin // Synchronous reset
        if (RST)
            PC_Out <= 32'h0;
        else if (PC_En)             
            PC_Out <= PC_In;           
    end
endmodule