`timescale 1ns / 1ps

module tb_reg_a;

	// Inputs
	reg clk;
	reg ce;
	reg rst;
	reg load;
	reg en;
	reg [7:0] bus;

	// Outputs
	wire [7:0] alu_out;
	wire [7:0] bus_out;

	// Instantiate the Unit Under Test (UUT)
	reg_a uut (
		.clk(clk), 
		.ce(ce), 
		.rst(rst), 
		.load(load), 
		.en(en), 
		.bus(bus), 
		.alu_out(alu_out), 
		.bus_out(bus_out)
	);

	initial begin
			clk = 0;
        forever #5 clk = ~clk;
	end
 
	initial begin
// TEST 1: RESET
rst = 1; ce = 0; load = 0; en = 0; bus = 8'hFF; 
        #10;
        check_result("Reset");

// TEST 2: LOAD DATA
rst = 0; 
        
        @(negedge clk); 
        ce = 1; load = 1; bus = 8'hAA; en = 0; 
        @(posedge clk); #1; 
        check_result("Load A");

// TEST 3: HOLD DATA
@(negedge clk);
        ce = 1; load = 0; bus = 8'h55; 
        
        @(posedge clk); #1;
        check_result("Hold (L=0)");

// TEST 4: CLOCK DISABLE
@(negedge clk);
        ce = 0; load = 1; bus = 8'h99; 
        
        @(posedge clk); #1;
        check_result("Clk Stop");
		  
// TEST 5: KIỂM TRA ENABLE OUTPUT
@(negedge clk);
        ce = 0; load = 0; en = 1; 
        #5;
        check_result("Out Enable");

        // Bước 5.2: Tắt En (Ngắt Bus)
        @(negedge clk);
        en = 0;
        #5;
// Kiểm tra High-Z 
        if (bus_out === 8'bz) 
            $display("| %4t |  %b  |  %b |   %b  |  %b |      --      |        %h        |          Z          | PASS  |", 
                     $time, rst, ce, load, en, alu_out);
        else
			$display("| %4t |  %b  |  %b |   %b  |  %b |      --      |        %h        |    FAIL (%h)     | FAIL  |", 
                     $time, rst, ce, load, en, alu_out, bus_out);

        $display("|______|_____|____|______|____|______________|__________________|_____________________|_______|");
        $finish;
    end
task check_result;
        input [8*2:1] state_name;
        begin

            $display("| %4t |  %b  |  %b |   %b  |  %b |      %h      |        %h        |          %h          | %-5s |", 
                     $time, rst, ce, load, en, bus, alu_out, bus_out, state_name);
        end
    endtask
	 
endmodule
