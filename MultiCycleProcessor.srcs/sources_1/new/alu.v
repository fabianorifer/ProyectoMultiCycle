module alu(
    input [31:0] SrcA, SrcB,
    input [2:0] ALUControl,
    output reg [31:0] ALUResult, Extend,
    output wire [3:0] ALUFlags
    );
    wire  neg, zero, carry, overflow;
    wire [31:0] condinvb;
    wire [32:0] sum; 
    assign condinvb = ALUControl[0] ? ~SrcB : SrcB;
    assign sum = SrcA + condinvb + ALUControl[0];
    
    always @(*) begin
        case (ALUControl)
        3'b000, 3'b001: ALUResult = sum; // add - sub
        3'b010: ALUResult = SrcA & SrcB; // and
        3'b011: ALUResult = SrcA | SrcB; // orr
        //3'b100: ALUResult = SrcA ^ SrcB; // eor
        3'b101: ALUResult = SrcA * SrcB; // multiplicacion
        3'b110: {Extend, ALUResult} = SrcA * SrcB;
        default: ALUResult = 32'b0;
        endcase
    end
    assign neg = ALUResult[31];
    assign zero = (ALUResult == 32'b0);
    assign carry = (ALUControl == 3'b000 || ALUControl == 3'b001) & sum[32];
    assign overflow = (ALUControl == 3'b000 || ALUControl == 3'b001)
    & ~(SrcA[31] ^ SrcB[31] ^ ALUControl[0]) & (SrcA[31] ^ sum[31]);

    assign ALUFlags = {neg, zero, carry, overflow};
endmodule
