`timescale 1ns / 1ps


module tb_ir;

	// Inputs
	reg clk;
	reg ce;
	reg rst;
	reg load;
	reg ei;
	reg [7:0] bus_in;

	// Outputs
	wire [3:0] opcode;
	wire [3:0] bus_out;

	// Instantiate the Unit Under Test (UUT)
	ir uut (
		.clk(clk), 
		.ce(ce), 
		.rst(rst), 
		.load(load), 
		.ei(ei), 
		.bus_in(bus_in), 
		.opcode(opcode), 
		.bus_out(bus_out)
	);
initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
	 
	initial begin
// TEST CASE 1: LDA 0D 
		  rst = 1; ce = 1; load = 0; ei = 0; bus_in = 0;
        #10;
        rst = 0;
@(negedge clk);
        bus_in = 8'h0D;
        load = 1; ei = 0; 
        @(posedge clk); #1; 


        load = 0; ei = 1; 
        #5; // Chờ ổn định
        
        check_result("LDA 0D", 8'h0D, 4'b0000, 4'b1101);		  
		  
// TEST CASE 2: ADD 1E		  
@(negedge clk);
        bus_in = 8'h1E;
        load = 1; ei = 0;
        @(posedge clk); #1;

        load = 0; ei = 1;
        #5;
        
        check_result("ADD 1E", 8'h1E, 4'b0001, 4'b1110);		

// TEST CASE 3: SUB 2F
@(negedge clk);
        bus_in = 8'h2F;
        load = 1; ei = 0;
		  
        @(posedge clk); #1;
        load = 0; ei = 1;
        #5;
        
        check_result("SUB 2F", 8'h2F, 4'b0010, 4'b1111);
		  
//TEST CASE 4: OUT E0
@(negedge clk);
    bus_in = 8'hE0;  
    load = 1; ei = 0;
    @(posedge clk); #1; 

    load = 0; ei = 1;
    #5;
    
    check_result("OUT E0", 8'hE0, 4'b1110, 4'b0000);

		  
// TEST CASE 5: HLT F0		  
@(negedge clk);
        bus_in = 8'hF0;
        load = 1; ei = 0;
        @(posedge clk); #1;

        load = 0; ei = 1;
        #5;
        
        check_result("HLT F0", 8'hF0, 4'b1111, 4'b0000);		  

// TEST CASE 6: KIỂM TRA HIGH-Z
@(negedge clk);
        load = 0; ei = 0; 
        #5;
		  if (bus_out === 4'bz && opcode == 4'b1111) // Vẫn giữ opcode cũ (F0)
            $display("| High-Z |     --      |     --      |      Z       |    %b     |      Z       |  PASS  |", opcode);
        else
            $display("| High-Z |     --      |     --      |      Z       |    %b     |     %b     |  FAIL  |", opcode, bus_out);

        $display("|________|_____________|_____________|______________|_____________|______________|________|");
        $finish;
    end
task check_result;
        input [8*6:1] test_name;
        input [7:0]   in_hex;
        input [3:0]   exp_opcode;
        input [3:0]   exp_operand;
        begin
		  if (opcode == exp_opcode && bus_out == exp_operand) begin
                $display("| %s |      %h     |    %b     |     %b     |    %b     |     %b     |  PASS  |", 
                         test_name, in_hex, exp_opcode, exp_operand, opcode, bus_out);
            end else begin
				$display("| %s |      %h     |    %b     |     %b     |    %b     |     %b     |  FAIL  |", 
                         test_name, in_hex, exp_opcode, exp_operand, opcode, bus_out);
            end
        end
    endtask

      
endmodule
