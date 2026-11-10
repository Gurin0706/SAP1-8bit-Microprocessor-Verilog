`timescale 1ns / 1ps

module adder(
	input[7:0] a,
	input[7:0] b,
	input sub,
	input eu,
	
	output[7:0] out
    );
   wire [7:0] result;
	 
    assign result = (sub) ? (a - b) : (a + b);
    assign out = (eu) ? result : 8'bz;

endmodule