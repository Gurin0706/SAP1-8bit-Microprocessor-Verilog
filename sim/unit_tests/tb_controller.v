
`timescale 1ns / 1ps

module tb_controller;

	// Inputs
	reg clk;
	reg ce;
	reg rst;
	reg [3:0] opcode;

	// Outputs
	wire [12:0] out;

	// Instantiate the Unit Under Test (UUT)
	controller uut (
		.clk(clk), 
		.ce(ce), 
		.rst(rst), 
		.opcode(opcode), 
		.out(out)
	);

initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end
	 
initial begin
        $display("==========================================================================================");
        $display("| Time | State | Opcode |           Control Signals (Bin)         | Expected (Bin)  | Result |");
        $display("|      |       |        | Lo Hlt Cp Ep Lm CE Li Ei La Ea Lb Su Eu | (From Image)    |        |");
        $display("|______|_______|________|_________________________________________|_________________|________|");

		  ce = 1; rst = 1; opcode = 0;
        #15; 
        rst = 0;
		  
//TEST 1: CHU KỲ FETCH (T1, T2, T3) - CHẠY TỰ ĐỘNG
// T1 (State 0): PC -> MAR (Ep, Lm = 1) -> 0001100000000
        wait_clock();
        check_step("T1/S0", 4'bxxxx, 13'b0001100000000);

        // T2 (State 1): PC + 1 (Cp = 1) -> 0010000000000
        wait_clock();
        check_step("T2/S1", 4'bxxxx, 13'b0010000000000);

        // T3 (State 2): RAM -> IR (CE, Li = 1) -> 0000001100000
        wait_clock();
        check_step("T3/S2", 4'bxxxx, 13'b0000001100000);
		  
// TEST 2: LỆNH LDA (Opcode 0000)
        opcode = 4'b0000; // Cập nhật Opcode để Controller xử lý tiếp
        
        // T4 (State 3): IR -> MAR (Lm, Ei = 1) -> 0000100100000
        wait_clock();
        check_step("LDA/T4", opcode, 13'b0000100100000);

        // T5 (State 4): RAM -> A (CE, La = 1) -> 0000010010000
        wait_clock();
        check_step("LDA/T5", opcode, 13'b0000010010000);

        // T6 (State 5): Nghi -> 0000000000000
        wait_clock();
        check_step("LDA/T6", opcode, 13'b0000000000000);

// TEST 3: LỆNH ADD (Opcode 0001)
		  rst = 1; #10; rst = 0; 
        opcode = 4'b0001;
        wait_clock(); // T1
        wait_clock(); // T2
        wait_clock(); // T3
        
        // T4 (State 3): IR -> MAR (Lm, Ei = 1) -> 0000100100000
        wait_clock();
        check_step("ADD/T4", opcode, 13'b0000100100000);
		  // T5 (State 4): RAM -> B (CE, Lb = 1) -> 0000010000100
        wait_clock();
        check_step("ADD/T5", opcode, 13'b0000010000100);

        // T6 (State 5): ALU -> A (La, Eu = 1) -> 0000000010001
        wait_clock();
        check_step("ADD/T6", opcode, 13'b0000000010001);

// TEST 4: LỆNH SUB (Opcode 0010)
        rst = 1; #10; rst = 0; opcode = 4'b0010;
        repeat(3) wait_clock(); // Bỏ qua T1, T2, T3
        
        // T4 (State 3): IR -> MAR (Lm, Ei = 1) -> 0000100100000
        wait_clock();
        check_step("SUB/T4", opcode, 13'b0000100100000);

        // T5 (State 4): RAM -> B (CE, Lb = 1) -> 0000010000100
        wait_clock();
        check_step("SUB/T5", opcode, 13'b0000010000100);

		  // T6 (State 5): ALU -> A (La, Su, Eu = 1) -> 0000000010011
        wait_clock();
        check_step("SUB/T6", opcode, 13'b0000000010011);

// TEST 5: LỆNH OUT (Opcode 1110)
        rst = 1; #10; rst = 0; opcode = 4'b1110;
        repeat(3) wait_clock(); // Bỏ qua Fetch
        
        // T4 (State 3): A -> Out_Reg (Lo, Ea = 1) -> 1000000001000
        wait_clock();
        check_step("OUT/T4", opcode, 13'b1000000001000);
		  
// TEST 6: LỆNH HLT (Opcode 1111)
        // ============================================================
        rst = 1; #10; rst = 0; opcode = 4'b1111;
        repeat(3) wait_clock(); // Bỏ qua Fetch
        
        // T4 (State 3): Halt (Hlt = 1) -> 0100000000000
        wait_clock();
        check_step("HLT/T4", opcode, 13'b0100000000000);

        $display("|______|_______|________|_________________________________________|_________________|________|");
        $finish;
    end

task wait_clock;
        begin
            @(negedge clk);
        end
    endtask

task check_step;
        input [8*6:1] step_name;
        input [3:0]   current_op;
        input [12:0]  expected;
        begin
            if (out == expected) begin
                $display("| %4t | %-5s |  %b  |      %b      |  %b  |  PASS  |", 
                         $time, step_name, current_op, out, expected);
					end else begin
                $display("| %4t | %-5s |  %b  |      %b      |  %b  |  FAIL  |", 
                         $time, step_name, current_op, out, expected);
            end
        end
    endtask
     
endmodule
