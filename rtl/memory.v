`timescale 1ns / 1ps

module memory(
	input clk,
   input ce,
	input rst,
	
	input load,
	input ro,
	input[7:0] bus,
	output[7:0] out 
    );

	reg[3:0] mar;
	reg[7:0] ram[0:15];

	initial begin
		$readmemh("program.bin", ram);
	end

	always @(posedge clk, posedge rst) begin
		if (rst) begin
			mar <= 4'b0000;
		end 
		else if (ce & load) begin
			mar <= bus[3:0];
		end
	end

	assign out = (~ro) ? ram[mar] : 8'bz;

endmodule