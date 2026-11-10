`timescale 1ns / 1ps
module sap1_top (
input clk_in,
input rst,
output [7:0] out_display
);

// Common Tri-State System Bus
wire [7:0] bus;

// Internal Clock & Control Signals
wire clk_out;
wire ce;
wire [12:0] ctrl;

// Control signal alias for readability
wire sig_out_load  = ctrl[12];
wire sig_hlt       = ctrl[11];
wire sig_pc_inc    = ctrl[10];
wire sig_pc_en     = ctrl[9];
wire sig_mar_ld    = ctrl[8];
wire sig_ram_ro    = ctrl[7];
wire sig_ir_load   = ctrl[6];
wire sig_ir_en     = ctrl[5];
wire sig_a_load    = ctrl[4];
wire sig_a_en      = ctrl[3];
wire sig_b_load    = ctrl[2];
wire sig_adder_sub = ctrl[1];
wire sig_adder_en  = ctrl[0];

// Internal Wires
wire [3:0] opcode;
wire [3:0] pc_to_bus;
wire [3:0] ir_to_bus;
wire [7:0] alu_to_adder;
wire [7:0] reg_b_to_adder;

// Tri-state drivers onto common bus
assign bus[3:0] = (sig_pc_en) ? pc_to_bus : 4'bz;
assign bus[3:0] = (sig_ir_en) ? ir_to_bus : 4'bz;
assign bus[7:4] = (sig_pc_en || sig_ir_en) ? 4'b0000 : 4'bz;

// 1. Clock Module
clock u_clock (
.clk_in(clk_in),
.rst(rst),
.hlt(sig_hlt),
.clk_out(clk_out),
.ce(ce)
);

// 2. Program Counter
pc u_pc (
.clk(clk_out),
.ce(ce),
.rst(rst),
.inc(sig_pc_inc),
.en(sig_pc_en),
.out(pc_to_bus)
);

// 3. Controller / FSM
controller u_controller (
.clk(clk_out),
.ce(ce),
.rst(rst),
.opcode(opcode),
.out(ctrl)
);

// 4. Memory (MAR + RAM)
memory u_memory (
.clk(clk_out),
.ce(ce),
.rst(rst),
.load(sig_mar_ld),
.ro(sig_ram_ro),
.bus(bus),
.out(bus)
);

// 5. Instruction Register
ir u_ir (
.clk(clk_out),
.ce(ce),
.rst(rst),
.load(sig_ir_load),
.ei(sig_ir_en),
.bus_in(bus),
.opcode(opcode),
.bus_out(ir_to_bus)
);

// 6. Accumulator (Register A)
reg_a u_reg_a (
.clk(clk_out),
.ce(ce),
.rst(rst),
.load(sig_a_load),
.en(sig_a_en),
.bus(bus),
.alu_out(alu_to_adder),
.bus_out(bus)
);

// 7. Register B
reg_b u_reg_b (
.clk(clk_out),
.ce(ce),
.rst(rst),
.load(sig_b_load),
.bus(bus),
.out(reg_b_to_adder)
);

// 8. Adder / Subtractor ALU
adder u_adder (
.a(alu_to_adder),
.b(reg_b_to_adder),
.sub(sig_adder_sub),
.eu(sig_adder_en),
.out(bus)
);

// 9. Output Register
out_reg u_out_reg (
.clk(clk_out),
.ce(ce),
.rst(rst),
.load(sig_out_load),
.bus(bus),
.out(out_display)
);

endmodule