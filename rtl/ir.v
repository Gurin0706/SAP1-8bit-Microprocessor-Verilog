`timescale 1ns / 1ps

module ir(
	input clk,
	input ce,
	input rst,
	input load,
	input ei,
	input[7:0] bus_in, 
	
	output[3:0] opcode, 
	output[3:0] bus_out 
    );

reg[7:0] ir;

    always @(posedge clk or posedge rst) begin 
        if (rst) begin
            ir <= 8'b00000000;
        end 
        else if (ce & load) begin 
            ir <= bus_in; 
        end
    end

    assign opcode = ir[7:4];
	 assign bus_out = (ei) ? ir[3:0] : 4'bz;


endmodule