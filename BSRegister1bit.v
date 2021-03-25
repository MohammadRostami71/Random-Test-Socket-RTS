//IEEE Std. 1149.1 Boundry Scan Verilog Description
`timescale 1 ns / 1ns
module BSRegister1bit(DIN, SIN, ShiftBR, UpdateBR, ClockBR, RstBar, ModeControl, SOUT, DOUT);

	input DIN, SIN, ShiftBR, UpdateBR;
	input ClockBR, RstBar, ModeControl;
	output SOUT, DOUT;
	
	wire D_DF1;
	reg Q_DF1, Q_DF2;
	assign D_DF1 = ShiftBR ? SIN : DIN;
	always @(posedge ClockBR, negedge RstBar)
		if(!RstBar) Q_DF1 <= 0; else Q_DF1 <= D_DF1;
	always @(posedge UpdateBR, negedge RstBar)
		if(!RstBar) Q_DF2 <= 0; else Q_DF2 <= Q_DF1;
	assign DOUT = ModeControl ? Q_DF2 : DIN;
	assign SOUT = Q_DF1;

endmodule