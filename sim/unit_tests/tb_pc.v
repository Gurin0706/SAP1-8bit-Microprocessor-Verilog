`timescale 1ns / 1ps

module tb_pc;

    // --- 1. Khai báo tín hiệu ---
    reg clk;
    reg ce;
    reg rst;
    reg inc;
	 reg en;
    
    wire [3:0] out;
	 reg [3:0] current_val;

    // --- 2. Kết nối Module PC ---
    pc uut (
        .clk(clk), 
        .ce(ce), 
        .rst(rst),
		  .en(en),
        .inc(inc), 
        .out(out)
    );
	// --- 3. Tạo xung Clock (10ns = 100MHz) ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --- 4. Kịch bản kiểm thử theo Bảng Trạng Thái ---
	initial begin
        // In tiêu đề bảng
        $display("=========================================================================");
        $display("   KIEM TRA LOGIC DUA TREN BANG TRANG THAI (STATE TABLE)                 ");
        $display("=========================================================================");
        $display("Time \t| rst | ce  | inc | Current Out | Next Out (Du Kien) | Ket Qua");
        $display("________|_____|_____|_____|_____________|____________________|_________");	 
		  
		  // ============================================================
        // DÒNG 1: ASYNCHRONOUS RESET
        // Logic: rst=1 -> out=0 ngay lap tuc
        // ============================================================
			rst = 1; ce = 0; inc = 0; en = 1;
        #5; // Chờ một chút (không cần chờ canh clock vì là async)
        
        if (out == 0) 
            $display("%0t \t|  1  |  X  |  X  |      X      |          0         | PASS", $time);
        else
            $display("%0t \t|  1  |  X  |  X  |      X      |          0         | FAIL", $time);

 	// DÒNG 2: HOLD (ce = 0)
        // Logic: rst=0, ce=0 -> Giữ nguyên giá trị cũ (đang là 0)
        // ============================================================
        @(negedge clk); // Đợi cạnh xuống để setup tín hiệu
        rst = 0; ce = 0; inc = 1; en = 1; // Cố tình bật inc nhưng tắt ce
        @(posedge clk); #1;       // Đợi cạnh lên xử lý + delay cập nhật	 
			if (out == 0)
            $display("%0t \t|  0  |  0  |  X  |      0      |          0         | PASS (Hold)", $time);
        else
            $display("%0t \t|  0  |  0  |  X  |      0      |          0         | FAIL", $time);

        // ============================================================
        // DÒNG 3: NO-OP (inc = 0)
        // Logic: rst=0, ce=1, inc=0 -> Giữ nguyên giá trị cũ (đang là 0)
        // ============================================================	 
		  @(negedge clk);
        rst = 0; ce = 1; inc = 0; en = 1;// Bật ce nhưng tắt inc
        @(posedge clk); #1;
        
        if (out == 0)
            $display("%0t \t|  0  |  1  |  0  |      0      |          0         | PASS (No-Op)", $time);
        else
            $display("%0t \t|  0  |  1  |  0  |      0      |          0         | FAIL", $time); 
				
			// ============================================================
        // DÒNG 4 -> 19: ĐẾM TỪ 0 ĐẾN 15
        // Logic: rst=0, ce=1, inc=1 -> Tăng dần
        // ============================================================
        $display("________|_____|_____|_____|_____________|____________________|_________");
        $display("   BAT DAU DEM (Counting Sequence 0->15)");
        
        rst = 0; ce = 1; inc = 1; en = 1;	
        repeat (15) begin
            current_val = out; 
            
            @(posedge clk); #1;
            
            if (out == current_val + 1)
				$display("%0t \t|  0  |  1  |  1  |      %2d     |         %2d         | PASS", 
                         $time, current_val, out);
            else
                $display("%0t \t|  0  |  1  |  1  |      %2d     |         %2d         | FAIL", 
                         $time, current_val, out);
        end
		  
		  // ============================================================
        // DÒNG 20: ROLLOVER (TRÀN SỐ)
        // Logic: Hiện tại đang là 15 -> Nhảy về 0
        // ============================================================
        if (out == 15) begin
            @(posedge clk); #1; // Nhảy thêm 1 nhịp nữa
		  if (out == 0)
                $display("%0t \t|  0  |  1  |  1  |      15     |          0         | PASS (Rollover)", $time);
            else
                $display("%0t \t|  0  |  1  |  1  |      15     |          0         | FAIL", $time);
        end

        $display("=========================================================================");
        $finish;
    end
	
endmodule
