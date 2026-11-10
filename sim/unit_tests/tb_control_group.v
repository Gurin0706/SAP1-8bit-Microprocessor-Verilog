`timescale 1ns / 1ps

module tb_control_group;

	reg clk, rst, ce;
	wire [7:0] common_bus;
    reg [7:0] tb_pc_addr; // Địa chỉ giả lập từ PC
    reg tb_drive_bus;     // Biến cho phép TB lái Bus
    assign common_bus = (tb_drive_bus) ? tb_pc_addr : 8'bz;
	 
	 wire [12:0] ctrl_out;
	 wire sig_hlt     = ctrl_out[11];
    wire sig_mar_ld  = ctrl_out[8];  // Lm
    wire sig_ram_ro  = ctrl_out[7];  // CE
    wire sig_ir_load = ctrl_out[6];  // Li
    wire sig_ir_en   = ctrl_out[5];  // Ei
    wire sig_a_load  = ctrl_out[4];  // La
	 wire sig_b_load  = ctrl_out[2];  // Lb
    wire sig_sub     = ctrl_out[1];  // Su
    wire sig_alu_en  = ctrl_out[0];  // Eu
    wire sig_out_ld  = ctrl_out[12]; // Lo

    // Dây Opcode từ IR -> Controller
    wire [3:0] opcode_wire;
	 wire [2:0] current_stage = u_ctrl.stage;
	 memory u_mem (
        .clk(clk), .ce(ce), .rst(rst),
        .load(sig_mar_ld), .ro(sig_ram_ro),
        .bus(common_bus), .out(common_bus)
    );

    ir u_ir (
        .clk(clk), .ce(ce), .rst(rst),
        .load(sig_ir_load), .ei(sig_ir_en),
        .bus_in(common_bus), 
        .opcode(opcode_wire), 
        .bus_out(common_bus[3:0])
    );
	 controller u_ctrl (
        .clk(clk), .ce(ce), .rst(rst),
        .opcode(opcode_wire), 
        .out(ctrl_out)
    );

    // Clock
    initial begin
        clk = 0; forever #5 clk = ~clk;
    end
	 
	 initial begin
        // 1. Khởi tạo
        rst = 1; ce = 1; tb_drive_bus = 0; tb_pc_addr = 0;
        

        // 2. Nạp chương trình vào RAM (Backdoor loading)
        u_mem.ram[0] = 8'h0D; // LDA 0D
        u_mem.ram[1] = 8'h1E; // ADD 1E
        u_mem.ram[2] = 8'h2F; // SUB 2F
        u_mem.ram[3] = 8'hE0; // OUT E0
        u_mem.ram[4] = 8'hF0; // HLT F0
		  
		  #20; rst = 0;
	 
// 1. Chạy lệnh tại địa chỉ 0 (LDA)
        run_fetch_cycle(0); // Giả lập PC cấp địa chỉ 0
        wait(u_ctrl.stage == 0); // Chờ Controller chạy hết vòng, quay về T0

        // 2. Chạy lệnh tại địa chỉ 1 (ADD)
        run_fetch_cycle(1); // Giả lập PC cấp địa chỉ 1
        wait(u_ctrl.stage == 0);

        // 3. Chạy lệnh tại địa chỉ 2 (SUB)
        run_fetch_cycle(2);
        wait(u_ctrl.stage == 0);

// 4. Chạy lệnh tại địa chỉ 3 (OUT)
        run_fetch_cycle(3);
        wait(u_ctrl.stage == 0);

        // 5. Chạy lệnh tại địa chỉ 4 (HLT)
        run_fetch_cycle(4);
        
        // Chờ xem HLT có dừng máy (đóng băng stage) không
        #50; 
        $stop;
    end	 
	 
	 // --- TASK GIẢ LẬP PC ---
    // Nhiệm vụ: Đợi đến T0, chiếm quyền Bus, nạp địa chỉ vào MAR
    task run_fetch_cycle;
        input [7:0] addr;
        begin
            // Đảm bảo Controller đang ở T0
            wait (u_ctrl.stage == 0);
            
            // Tại sườn xuống, đưa địa chỉ ra Bus
            @(negedge clk);
            tb_pc_addr = addr;
            tb_drive_bus = 1; // Testbench chiếm Bus
				
	// Tại sườn lên, MAR sẽ load (vì Controller đang bật Lm ở T0)
            @(posedge clk);
				#1; 
            
            // Thả Bus ra
            tb_drive_bus = 0;
            
            // Đợi một chút để thoát khỏi T0
            
        end
    endtask

endmodule