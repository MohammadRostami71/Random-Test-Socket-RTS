 `timescale 1 ns / 1ns

module SISR #(parameter n = 8) (input clk, init, en, sin, input [n - 1:0]poly, seed, output reg [n - 1:0] Q);
	integer i;
	always @(posedge clk, posedge init) begin
		if (init == 1'b1) Q <= seed;
		else if (en == 1'b1) begin
			Q[n - 1] <= Q[0] ^ sin;
			for (i = 0; i < n - 1; i = i + 1) begin
				Q[i] <= (Q[0] & poly[i]) ^ Q[i + 1];
			end //for
		end
	end
endmodule