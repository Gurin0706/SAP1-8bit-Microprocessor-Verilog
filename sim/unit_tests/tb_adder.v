`timescale 1ns / 1ps

module tb_adder;

	// Inputs
	reg [7:0] a;
	reg [7:0] b;
	reg sub;
	reg eu;

	wire [7:0] out;

	// Instantiate the Unit Under Test (UUT)
	adder uut (
		.a(a), 
		.b(b), 
		.eu(eu),
		.sub(sub), 
		.out(out)
	);

	initial begin
$display("Time \t| Mode |  A  |  B  | Exp(Dec) | Out(Dec) | Out(Bin) | Result");
$display("________|______|_____|_____|__________|__________|__________|_______");	
		
// --- TRƯỜNG HỢP 1: CỘNG BÌNH THƯỜNG ---
        // 10 + 20 = 30
		  eu = 1;
        sub = 0; a = 10; b = 20;
        #10;
		  $display("%0t \t| ADD  |    %3d    |    %3d    |      %3d     |   %b", 
			$time, a, b, out, out);
			
// --- TRƯỜNG HỢP 2: CỘNG TRÀN SỐ (OVERFLOW) ---
        // 250 + 10 = 260 -> Tràn bit -> Còn 4
        sub = 0; a = 250; b = 10;
        #10;
        $display("%0t \t| ADD  |    %3d    |    %3d    |      %3d     |   %b  (Tran so)", 
                 $time, a, b, out, out);			
			
// --- TRƯỜNG HỢP 3: TRỪ BÌNH THƯỜNG ---
        // 50 - 20 = 30
        sub = 1; a = 50; b = 20;
        #10;
        $display("%0t \t| SUB  |    %3d    |    %3d    |      %3d     |   %b", 
                 $time, a, b, out, out);	
					  
// --- TRƯỜNG HỢP 4: TRỪ RA SỐ ÂM (UNDERFLOW) ---
        // 10 - 20 = -10 (Trong hệ bù 2 8-bit là 246)
        sub = 1; a = 10; b = 20;
        #10;
        $display("%0t \t| SUB  |    %3d    |    %3d    |      %3d     |   %b  (So am/Bu 2)", 
                 $time, a, b, out, out);

        $display("----------------------------------------------------------------------");

		eu = 0;
		#10;
        if (out === 8'bz)
            $display("%0t \t| OFF  |  %3d |  %3d |     Z    |  ZZZZZZZZ  | Tri-state OK", $time, a, b);
        else
            $display("%0t \t| OFF  |  %3d |  %3d |    %3d   |  %b  | FAIL (Should be Z)", $time, a, b, out, out);

        $display("----------------------------------------------------------------------------");
        $finish;        	  
			
	end	
endmodule