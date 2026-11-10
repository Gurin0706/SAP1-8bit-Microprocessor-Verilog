`timescale 1ns / 1ps

module tb_memory;

	// Inputs
	reg clk;
	reg ce;
	reg rst;
	reg load;
	reg ro;
	reg [7:0] bus;

	// Outputs
	wire [7:0] out;

	// Instantiate the Unit Under Test (UUT)
	memory uut (
		.clk(clk), 
		.ce(ce), 
		.rst(rst), 
		.load(load), 
		.ro(ro), 
		.bus(bus), 
		.out(out)
	);

	initial begin
	clk = 0;
        forever #5 clk = ~clk;

	end
   
initial begin
        
        ce = 1;        
        rst = 1;       
        load = 0;
        ro = 0;
        bus = 8'b0;

        #20;
        rst = 0;
		  
		  uut.ram[0] = 8'b00001001; // 0H: LDA 9H
        uut.ram[1] = 8'b00011010; // 1H: ADD AH
        uut.ram[2] = 8'b00011011; // 2H: ADD BH
        uut.ram[3] = 8'b00101100; // 3H: SUB CH
        uut.ram[4] = 8'b11100000; // 4H: OUT 
        uut.ram[5] = 8'b11110000; // 5H: HLT
		  
		  // TEST 1: Đọc địa chỉ 0H 
        #10;
        drive_address(4'h0);    
        read_data();            
        
        // TEST 2: Đọc địa chỉ 1H (Mong đợi: 0001 1010)
        #10;
        drive_address(4'h1);
        read_data();
		  
		  // TEST 3: Đọc địa chỉ 3H (Mong đợi: 0010 1100)
        #10;
        drive_address(4'h3);
        read_data();

        // Kết thúc mô phỏng
        #20;
        $finish;
    end
	 
   // --- Task hỗ trợ 1: Đưa địa chỉ vào MAR ---
	task drive_address;
        input [3:0] addr;
        begin
            $display("1. Nap dia chi: %h vao MAR", addr);
            bus = {4'b0000, addr}; 
            load = 1;              
            #10;                   
            load = 0;              
            bus = 8'bz;            
        end
    endtask
	
	// --- Task hỗ trợ 2: Đọc dữ liệu từ RAM ---
    task read_data;
        begin
            ro = 1;                
            #5;                    
            $display("2. Du lieu tai out: %b (Hex: %h)", out, out);
            #5;                    
            ro = 0;                
        end
    endtask
	
endmodule