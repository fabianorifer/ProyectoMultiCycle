// ADD CODE BELOW
// Complete the datapath module below for Lab 11.
// You do not need to complete this module for Lab 10.
// The datapath unit is a structural SystemVerilog module. That is,
// it is composed of instances of its sub-modules. For example,
// the instruction register is instantiated as a 32-bit flopenr.
// The other submodules are likewise instantiated. 
module datapath (
	clk,
	reset,
	Adr,
	WriteData,
	ReadData,
	Instr,
	ALUFlags,
	PCWrite,
	RegWrite,
	IRWrite,
	AdrSrc,
	RegSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	ImmSrc,
	ALUControl
);
	input wire clk;
	input wire reset;
	output wire [31:0] Adr;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
	output wire [31:0] Instr;
	output wire [3:0] ALUFlags;
	input wire PCWrite;
	input wire RegWrite;
	input wire IRWrite;
	input wire AdrSrc;
	input wire [1:0] RegSrc;
	input wire [1:0] ALUSrcA;
	input wire [1:0] ALUSrcB;
	input wire [1:0] ResultSrc;
	input wire [1:0] ImmSrc;
	input wire [2:0] ALUControl;
	wire [31:0] PCNext;
	wire [31:0] PC;
	wire [31:0] ExtImm;
	wire [31:0] SrcA;
	wire [31:0] SrcB;
	wire [31:0] Result;
	wire [31:0] Data;
	wire [31:0] RD1;
	wire [31:0] RD2;
	wire [31:0] A;
	wire [31:0] ALUResult;
	wire [31:0] ALUOut;
	wire [31:0] Large;
	wire [3:0] RA1;
	wire [3:0] RA2;
	wire [3:0] mulRA1;
	wire [3:0] mulRA2;
	wire [3:0] Rd;
	wire [3:0] Ra;
	//wire [3:0] res;
	reg [3:0] res;
	wire [31:0] Large1;
	wire [31:0] Large2;
	
	//cambiar el formato (harris &harris)
	assign mulRA1 = (Instr[7:4] == 4'b1001) ? Instr[3:0] : Instr[19:16];
	
	assign mulRA2 = (Instr[7:4] == 4'b1001) ? Instr[11:8] : Instr[3:0];
	
	//resultado RD - (MUL):
	//assign res = (Instr[7:4] == 4'b1001) ? Instr[19:16] : Instr[15:12];
	
	//Registros Destinos Ra y Rd:
    assign Rd = Instr[15:12];  // <- Registro destino (correcto)
    assign Ra = Instr[19:16];  // <- Rn (fuente, correcto)

	
	//resultado Rd, Ra - (UMULL):
	
	always @(*) begin
    if (Instr[7:4] == 4'b1001) begin
        // Instrucción UMULL
        if (ResultSrc == 2'b11)
            res = Rd; // Parte baja primero
        else
            res = Ra; // Parte alta después
    end else begin
        // Para cualquier otra instrucción
        if (ResultSrc == 2'b00)
            res = Rd;
        else if (ResultSrc == 2'b11)
            res = Ra;
        else
            res = Rd;
    end
end
	       

	
	/*
	assign res = (ResultSrc == 2'b00) ? Rd :
             (ResultSrc == 2'b11) ? Ra : 
             ((Instr[7:4] == 4'b1001) ? Ra : Rd);
             */

	
	
	
	//resultado UMUL:
	//assign res = (state == 4'd13) ? Instr[15:12] : ((Instr[7:4] == 4'b1001) ? Instr[19:16] : Instr[15:12]);

	// Your datapath hardware goes below. Instantiate each of the 
	// submodules that you need. Remember that you can reuse hardware
	// from previous labs. Be sure to give your instantiated modules 
	// applicable names such as pcreg (PC register), adrmux 
	// (Address Mux), etc. so that your code is easier to understand.

	// ADD CODE HERE
	
	//ADD: PC Register 
	flopenr #(32) pcreg(
		.clk(clk),
		.reset(reset),
		.en(PCWrite),
		.d(Result),
		.q(PC)
	);
	
	//ADD: AdressMux - MUX2
	mux2 #(32) adrmux(
		.d0(PC),
		.d1(Result),
		.s(AdrSrc),
		.y(Adr)
	);
	
	//ADD: Module Extend
	extend ext(
		.Instr(Instr[23:0]),
		.ImmSrc(ImmSrc),
		.ExtImm(ExtImm)
	);
	
	// ADD: alu
	alu alu(
		.SrcA(SrcA),
		.SrcB(SrcB),
		.ALUControl(ALUControl),
		.ALUResult(ALUResult),
		.Large(Large),
		.ALUFlags(ALUFlags)
	);
	
	// ADD: RegFile
	regfile rf(
		.clk(clk),
		.we3(RegWrite),
		.ra1(RA1),
		.ra2(RA2),
		.wa3(res),
		.wd3(Result),
		.r15(Result),
		.rd1(RD1),
		.rd2(RD2)
	);
	
	// ADD: RA1 - Mux2
	mux2 #(4) ra1mux(
		.d0(mulRA1),
		.d1(4'b1111),
		.s(RegSrc[0]),
		.y(RA1)
	);
	
	// ADD: RA2 - Mux2
	mux2 #(4) ra2mux(
		.d0(mulRA2),
		.d1(Instr[15:12]),
		.s(RegSrc[1]),
		.y(RA2)
	);
	
	// ADD: RegistroEnable-InstrMemory - FLOPENR
	flopenr #(32) reginstr(
		.clk(clk),
		.reset(reset),
		.en(IRWrite),
		.d(ReadData),
		.q(Instr)
	);
	
	// ADD: RegistroInstr/DataMemory-RegFile - FLOPR
	flopr #(32) regread_data(
		.clk(clk),
		.reset(reset),
		.d(ReadData),
		.q(Data)
	);
	
	// ADD: Registro-RegFile - FLOPREGFILE.v
	flopregfile #(32) regfiledata(
		.clk(clk),
		.reset(reset),
		.d0(RD1),
		.d1(RD2),
		.q0(A),
		.q1(WriteData)
	);
	
	// ADD: SrcA-MUX3
	mux3 #(32) srcamux(
		.d0(A),
		.d1(PC),
		.d2(ALUOut),
		.s(ALUSrcA),
		.y(SrcA)
	);
	
	
	// ADD: SrcB-MUX3
	mux3 #(32) srcbmux(
		.d0(WriteData),
		.d1(ExtImm),
		.d2(4),
		.s(ALUSrcB),
		.y(SrcB)
	);
	
	// ADD: Registro-ALUResult-FLOPR
	flopr #(32) regaluresult(
		.clk(clk),
		.reset(reset),
		.d(ALUResult),
		.q(ALUOut)
	);
	
	flopr #(32) large1(
		.clk(clk),
		.reset(reset),
		.d(Large),
		.q(Large1)
	);
	
	flopr #(32) large2(
		.clk(clk),
		.reset(reset),
		.d(Large1),
		.q(Large2)
	);
	
	
	
	
	// ADD: resultmux - MUX3
	mux4 #(32) resmux(
		.d0(ALUOut),
		.d1(Data),
		.d2(ALUResult),
		.d3(Large2),
		.s(ResultSrc),
		.y(Result)
	);
	
	
endmodule