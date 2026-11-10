`timescale 1ns / 1ps

module tb_clock;

	// Inputs
	reg hlt;
	reg rst;
	reg clk_in;

	// Outputs
	wire clk_out;
	wire ce;

	// Instantiate the Unit Under Test (UUT)
clock #(.MAX_COUNT(4)) uut (
        .clk_in(clk_in), 
        .rst(rst), 
        .hlt(hlt), 
        .clk_out(clk_out), 
        .ce(ce)
    );

	initial begin
		  clk_in = 0;
        forever #5 clk_in = ~clk_in; 
	end

	initial begin
        // --- Giai đoạn 1: Reset hệ thống ---
        rst = 1;
        hlt = 0;
        #20; 
        
        // Thả Reset -> Bắt đầu đếm
        rst = 0; 

        // --- Giai đoạn 2: Chạy bình thường ---
        // Cho chạy khoảng 100ns để quan sát xung ce
        #100;
	// --- Giai đoạn 3: Kiểm tra tín hiệu HALT ---
        @(negedge clk_in); 
        hlt = 1;           
        
        // Giữ Halt trong 60ns (Lúc này ce phải nằm im ở mức 0)
        #60;

        // --- Giai đoạn 4: Tắt HALT (Chạy lại) ---
        @(negedge clk_in);
        hlt = 0;           
        
        #100; 

        $stop;
    end
   
endmodule
