`timescale 1ns / 1ps

module pc(
	input clk,
   input ce,
	input rst,
	input inc,
	input en,
	output[3:0] out
    );
reg[3:0] pc;

  always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 4'b0000;
        end
		  else if (ce) begin
            if (inc) begin
                pc <= pc + 1;
            end
        end
    end

    assign out =(en) ? pc : 4'bz;

endmodule