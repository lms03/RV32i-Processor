//////////////////////////////////////////////////////////////////////////////////                                                           
// Third Year Project: RISC-V RV32i Pipelined Processor
// File: Fetch                                                   
// Description: Holds all decode stage modules.
//              Control Unit: 
//                  Generates control signals using the instruction opcodes.       
//              Register File:
//                  Contains the registers and controls access to them.
// Author: Luke Shepherd                                                     
// Date Created: November 2024                                                                                                                                                                                                                                                       
//////////////////////////////////////////////////////////////////////////////////

module decode (

);

endmodule

module control_unit (
    input wire [6:0] OP,
    input wire [2:0] Func3,
    input wire [6:0] Func7,
    output wire REG_W_En, MEM_W_En, Jump_En, Branch_En, 
    output wire MEM_Control, ALU_Control, 
    output wire Imm_Type_Sel,
    output wire ALU_Src_Sel, AUIPC, // ALU_Src 0 is register data, 1 is immediate. AUIPC 0 is normal SrcA, 1 is PC. 
    output wire [1:0] Result_Src_Sel // 00 is ALU output, 01 is memory output, 10 is PC+4, 11 is unused.
    // Width of MEM_Control, ALU_Control, Imm_Type_Sel not known yet.
    );

    case (OP)
        7'b0110011: // R-Type
        begin
            REG_W_En = 1; // Result stored in register
            MEM_W_En = 0; // No memory storage
            MEM_Control = X; // Unused
            Jump_En = 0; // No jump in this type
            Branch_En = 0; // No branch in this type
            ALU_Control = X; // Changed depending on specific opcode 
            AUIPC = 0; // Not AUIPC
            ALU_Src_Sel = 0; // Use the register data rather than immediate
            Imm_Type_Sel = X; // Unused
            Result_Src_Sel = 2'b00; // Select ALU output
            case (Func3)
                3'b000:
                    Func7 == 7'b0000000 ? ALU_Control = ?'b??? : ALU_Control = ?'b???; // ADD or SUB
                3'b001:
                    ALU_Control = ?'b???; //SLL
                3'b010:
                    ALU_Control = ?'b???; //SLT
                3'b011:
                    ALU_Control = ?'b???; //SLTU
                3'b100:
                    ALU_Control = ?'b???; //XOR
                3'b101:
                    Func7 == 7'b0000000 ? ALU_Control = ?'b??? : ALU_Control = ?'b???; // SRL or SRA
                3'b110:
                    ALU_Control = ?'b???; //OR
                3'b111:
                    ALU_Control = ?'b???; //AND
            endcase
        end
        7'b0000011: // I-Type

        7'b0000011: // S-Type

        7'b0000011: // B-Type

        7'b0110111: // LUI
        begin
            REG_W_En = 1; // Result stored in register
            MEM_W_En = 0; // No memory storage
            MEM_Control = X; // Unused
            Jump_En = 0; // Not a jump
            Branch_En = 0; // Not a branch
            ALU_Control = ?'b???; // Same as ADD, add the two 32bit sources (Immediate).
            AUIPC = 0; // Not AUIPC
            ALU_Src_Sel = 1; // Select immediate
            Imm_Type_Sel = ?; // U-Type immediate
            Result_Src_Sel = 2'b00; // Select ALU output
        end
        7'b0010111: // AUIPC
        begin

        end
        7'b0000011: // J-Type
        begin

        end

        default: // Invalid, even illegal instructions have types so propagate X's for detection.
        begin
            REG_W_En = X;
            Result_Src_Sel = X;
            MEM_W_En = X;
            MEM_Control = X;
            Jump_En = X;
            Branch_En = X;
            ALU_Control = X;
            ALU_Src_Sel = X;
            Imm_Type_Sel = X;
        end
    endcase
endmodule

module register_file (
    input wire CLK, RST, REG_W_En,
    input wire [4:0] REG_R_Addr1, REG_R_Addr2, REG_W_Addr,
    input wire [31:0] REG_W_Data
    output wire [31:0] REG_R_Data1, REG_R_Data2
    );

    reg [31:0] registers [31:0];

    always @ (posedge CLK) begin
        if (RST)
            for (int i = 0; i < 32; i++)
                registers[i] <= 32'h0;
        else if (REG_W_En)
            registers[REG_W_Addr] <= REG_W_Data;
        else
            REG_R_Data1 <= registers[REG_R_Addr1];
            REG_R_Data2 <= registers[REG_R_Addr2];
    end
endmodule

