module adder (
    input wire [31:0] A,
    input wire [31:0] B,
    output reg [31:0] OUT
    );

    assign OUT = A + B;
endmodule