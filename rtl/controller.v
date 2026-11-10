`timescale 1ns / 1ps

module controller(
	input clk,
	input ce,
	input rst,
	input[3:0] opcode,
	output reg[12:0] out
    );

localparam SIG_HLT       = 11;
localparam SIG_PC_INC    = 10;
localparam SIG_PC_EN     = 9;
localparam SIG_MAR_LD    = 8;
localparam SIG_RAM_RO    = 7;
localparam SIG_IR_LOAD   = 6;
localparam SIG_IR_EN     = 5;
localparam SIG_A_LOAD    = 4;
localparam SIG_A_EN      = 3;
localparam SIG_B_LOAD    = 2;
localparam SIG_ADDER_SUB = 1;
localparam SIG_ADDER_EN  = 0;
localparam SIG_OUT_LOAD  = 12;
//opcode
localparam OP_LDA = 4'b0000;
localparam OP_ADD = 4'b0001;
localparam OP_SUB = 4'b0010;
localparam OP_HLT = 4'b1111;
localparam OP_OUT = 4'b1110;

reg[2:0]  stage;

  always @(*) begin
        out = 13'b0; 
        case (stage)
            0: begin // T0: PC -> MAR
                out[SIG_PC_EN]    = 1;
                out[SIG_MAR_LD] = 1;
            end
            1: begin // T1: PC tăng 1
                out[SIG_PC_INC]   = 1;
            end
            2: begin // T2: RAM -> IR
                out[SIG_RAM_RO]   = 1;
                out[SIG_IR_LOAD]  = 1;
            end
            3: begin // T3
                case (opcode)
                    OP_LDA, OP_ADD, OP_SUB: begin
                        out[SIG_IR_EN]    = 1; 
                        out[SIG_MAR_LD] = 1; 
                    end
                    OP_OUT: begin
                        out[SIG_A_EN]     = 1; 
                        out[SIG_OUT_LOAD] = 1; 
                    end
                    OP_HLT: begin
                        out[SIG_HLT]      = 1; 
                    end
                endcase
            end						  
            4: begin // T4
                case (opcode)
                    OP_LDA: begin // RAM -> A
                        out[SIG_RAM_RO] = 1;
                        out[SIG_A_LOAD] = 1;
                    end
                    OP_ADD, OP_SUB: begin // RAM -> B
                        out[SIG_RAM_RO] = 1;
                        out[SIG_B_LOAD] = 1;
                    end
                endcase
            end
            5: begin // T5
                case (opcode)
                    OP_ADD: begin 
                        out[SIG_ADDER_EN] = 1;
                        out[SIG_A_LOAD]   = 1;
                    end
                    OP_SUB: begin 
                        out[SIG_ADDER_SUB]= 1;
                        out[SIG_ADDER_EN] = 1;
                        out[SIG_A_LOAD]   = 1;
                    end
                endcase
            end
        endcase
    end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            stage <= 0;
        end 
        else if (ce) begin

            if (stage == 3 && opcode == OP_HLT) begin
                stage <= 3; 
            end

            else if (stage == 5) begin
                stage <= 0;
            end

            else begin
                stage <= stage + 1;
            end
        end
    end
				
endmodule