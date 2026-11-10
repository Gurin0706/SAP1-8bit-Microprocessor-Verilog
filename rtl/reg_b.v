`timescale 1ns / 1ps

module reg_b(
	input clk,
	input ce,
	input rst,
	input load,
	input[7:0] bus,
	output[7:0] out
    );

reg[7:0] reg_b;

    always @(posedge clk or posedge rst) begin 
        if (rst) begin
            reg_b <= 8'b00000000; 
        end 
        else if (ce & load) begin 
            reg_b <= bus;
        end
    end

    assign out = reg_b;

endmodule