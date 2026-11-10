`timescale 1ns / 1ps
module out_reg(
    input clk,
    input ce,       
    input rst,
    input load,     
    input [7:0] bus,     
    output[7:0] out
    );

	reg [7:0] data_out;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= 8'b00000000;
        end 
        else if (ce & load) begin 
            data_out <= bus;
        end
        
    end
    
    assign out = data_out;

endmodule