`timescale 1ns / 1ps

module reg_a(
	input clk,
	input ce,
	input rst,
	input load,
	input en,
	input[7:0] bus,
	
	output[7:0] alu_out,
	output[7:0] bus_out
    );

reg[7:0] reg_a;

always @(posedge clk, posedge rst) begin
	if (rst) begin
		reg_a <= 8'b00000000;
	end
	else if (ce) begin
		if (load) begin
			reg_a <= bus;
			end
		end
	end

assign alu_out = reg_a;
assign bus_out = (en) ? reg_a : 8'bz;

endmodule