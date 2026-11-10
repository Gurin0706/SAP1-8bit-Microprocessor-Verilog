`timescale 1ns / 1ps

module tb_calc_group;
    reg clk;
    reg rst;
    reg ce; 
    wire [7:0] common_bus;

    reg [7:0] tb_data;
    reg tb_drive_bus; 
    assign common_bus = (tb_drive_bus) ? tb_data : 8'bz;
	
    reg load_a;
    reg en_a;
    reg load_b;
    reg sub;
    reg eu;

    wire [7:0] a_to_alu;
	 
reg_a u_reg_a (
        .clk(clk), .ce(ce), .rst(rst),
        .load(load_a), .en(en_a),
        .bus(common_bus),      
        .alu_out(a_to_alu),     
        .bus_out(common_bus)   
    );

wire [7:0] b_to_alu;
    reg_b u_reg_b (
        .clk(clk), .ce(ce), .rst(rst),
        .load(load_b),
        .bus(common_bus),
        .out(b_to_alu)          
    );

adder u_adder (
        .a(a_to_alu), .b(b_to_alu),
        .sub(sub), .eu(eu),
        .out(common_bus)        
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

	initial begin
		rst = 1; ce = 1; 
        load_a = 0; en_a = 0; load_b = 0; sub = 0; eu = 0;
        tb_drive_bus = 0;
        #15;
        rst = 0;	
	
@(negedge clk);
        tb_data = 10; tb_drive_bus = 1; 
        load_a = 1;
        @(posedge clk); #1;
        load_a = 0;	
	
@(negedge clk);
        tb_data = 20; tb_drive_bus = 1;
        load_b = 1;
        @(posedge clk); #1;
        load_b = 0;	
	
@(negedge clk);
        tb_drive_bus = 0; 
        sub = 0;
        eu = 1;  
        #5;	 

@(negedge clk);
        sub = 1;
        #5;
        eu = 0;
end

endmodule
	 