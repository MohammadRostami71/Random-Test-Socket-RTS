//IEEE Std. 1149.1 Boundry Scan Verilog Description
`timescale 1 ns / 1ns
module BS_BSR #(parameter Length = 1) (DIN, SIN, UpdateBR, ClockBR, ShiftBR, ModeControl, RstBar, SOUT, DOUT);

	input[Length-1:0] DIN;
	input SIN, ShiftBR, UpdateBR, ClockBR, RstBar, ModeControl;
	output SOUT;
	output[Length-1:0] DOUT;
	wire[Length-1:0] SIN_im;
	genvar i;
	generate for (i=0; i<Length; i=i+1) begin
		if(i == 0) begin
			BSRegister1bit l1 (.DIN(DIN[i]), .SIN(SIN), .ShiftBR(ShiftBR),
								.UpdateBR(UpdateBR), .ClockBR(ClockBR),
								.RstBar(RstBar), .ModeControl(ModeControl),
								.SOUT(SIN_im[1]), .DOUT(DOUT[i]));
		end
		else if (i > 0 & i < Length-1) begin
			BSRegister1bit l2_n (.DIN(DIN[i]), .SIN(SIN_im[i]), .ShiftBR(ShiftBR),
								.UpdateBR(UpdateBR), .ClockBR(ClockBR),
								.RstBar(RstBar), .ModeControl(ModeControl),
								.SOUT(SIN_im[i+1]), .DOUT(DOUT[i]));
		end
		else if(i == Length-1) begin
			BSRegister1bit ln (.DIN(DIN[i]), .SIN(SIN_im[i]), .ShiftBR(ShiftBR),
								.UpdateBR(UpdateBR), .ClockBR(ClockBR),
								.RstBar(RstBar), .ModeControl(ModeControl),
								.SOUT(SOUT), .DOUT(DOUT[i]));
		end
	end
	endgenerate

endmodule