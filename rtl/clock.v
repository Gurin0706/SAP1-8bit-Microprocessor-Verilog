`timescale 1ns / 1ps

module clock(
    input  clk_in,
    input  rst,
    input  hlt,
    output clk_out,
    output ce
	);
    assign clk_out = clk_in;
    parameter MAX_COUNT = 5; 

    reg [25:0] counter;
    reg        ce_slow;
    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter <= 0;
            ce_slow <= 0;
        end
        else begin
            if (counter == MAX_COUNT - 1) begin
                counter <= 0;
                ce_slow <= 1;
            end
            else begin
                counter <= counter + 1;
                ce_slow <= 0;
            end
        end
    end
    assign ce = ce_slow & (~hlt);

endmodule