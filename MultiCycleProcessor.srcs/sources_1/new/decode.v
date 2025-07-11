module decode (
	clk,
	reset,
	Op,
	Funct,
	Rd,
	MUL, // add
	FlagW,
	PCS,
	NextPC,
	RegW,
	MemW,
	IRWrite,
	AdrSrc,
	ResultSrc,
	ALUSrcA,
	ALUSrcB,
	ImmSrc,
	RegSrc,
	ALUControl
);
	input wire clk;
	input wire reset;
	input wire [1:0] Op;
	input wire [5:0] Funct;
	input wire [3:0] Rd;
	input wire [3:0] MUL;
	output reg [1:0] FlagW;
	output wire PCS;
	output wire NextPC;
	output wire RegW;
	output wire MemW;
	output wire IRWrite;
	output wire AdrSrc;
	output wire [1:0] ResultSrc;
	output wire [1:0] ALUSrcA;
	output wire [1:0] ALUSrcB;
	output wire [1:0] ImmSrc;
	output wire [1:0] RegSrc;
	output reg [2:0] ALUControl;
	wire Branch;
	wire ALUOp;

	mainfsm fsm(
		.clk(clk),
		.reset(reset),
		.Op(Op),
		.Funct(Funct),
		.IRWrite(IRWrite),
		.AdrSrc(AdrSrc),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.MUL(MUL),
		.ResultSrc(ResultSrc),
		.NextPC(NextPC),
		.RegW(RegW),
		.MemW(MemW),
		.Branch(Branch),
		.ALUOp(ALUOp)
	);
    // ALU DECODER
	always @(*)
	if (ALUOp) 
	begin
	  // cmd: MUL
	  if(MUL == 4'b1001) begin 
	   case (Funct[4:1])
	       4'b0000: ALUControl = 3'b101; // mul - 5
	       4'b0100: ALUControl = 3'b110; // umul - 6
	       //4'b0110: ALUControl = 3'b010; // smul - 7
	       default: ALUControl = 3'bxxx;
	   endcase
	   FlagW[1] = Funct[0];
       FlagW[0] = Funct[0] & ((ALUControl == 3'b000) | (ALUControl == 3'b001));
	 end
	 
	 else
	   case (Funct[4:1])  
			4'b0100: ALUControl = 3'b000; // add - 0
			4'b0010: ALUControl = 3'b001; // sub - 1
			4'b0000: ALUControl = 3'b010; // and - 2
			4'b1100: ALUControl = 3'b011; // orr - 3
			4'b1101: ALUControl = 3'b100; // mov - 4
			4'b1010: ALUControl = 3'b111; // udiv - 7
			default: ALUControl = 3'bxxx;
			endcase
			
		FlagW[1] = Funct[0];
        FlagW[0] = Funct[0] & ((ALUControl == 3'b000) | (ALUControl == 3'b001));
	end
	else begin
		ALUControl = 3'b000;
		FlagW = 2'b00;
	end

	assign PCS = ((Rd == 4'b1111) & RegW) | Branch;

	assign ImmSrc = Op;
	assign RegSrc[1] = Op == 2'b01;
	assign RegSrc[0] = Op == 2'b10;
endmodule
