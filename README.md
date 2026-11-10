# SAP-1 (Simple-As-Possible 1) 8-Bit Microprocessor Architecture

## 1. Overview
This project presents a synthesizable **RTL implementation** and **functional verification** of an 8-bit SAP-1 (Simple-As-Possible 1) microprocessor based on the Von Neumann architecture, described in *Digital Computer Electronics* by Albert P. Malvino. 

The architecture features a single 8-bit common data bus utilizing **tri-state buffers** to eliminate data contention across shared registers and memory interfaces. A 6-stage finite state machine (FSM) sequence controls the instruction execution pipeline.

---
> 📄 **Full Technical Report:** [Read SAP-1 Microprocessor Design Report (PDF)](docs/SAP1_Report.pdf)
---

## 2. Hardware Architecture & Block Diagram

```
                 +---------------------------------------------+
                 |               8-Bit Common Bus              |
                 +----+--------+--------+--------+--------+----+
                      |        ^        ^        ^        |
                     (in)    (out)    (out)    (out)    (in)
                      v        |        |        |        v
                   +----+    +----+   +----+   +----+   +----+
                   | MAR|    | PC |   | IR |   | A  |   |OUT |
                   +----+    +----+   +----+   +----+   +----+
                      |                 |        |        |
                      v                 v        v        v
                   +----+            Opcode   [ ALU ]  Display
                   |RAM |               |        ^
                   +----+               v        |
                      |            +---------+ +----+
                      +----------->| Control | | B  |
                                   | Unit    | +----+
                                   +---------+
```

### Key Subsystem Components:
* **Clock Generator (`clock.v`):** Generates clock enable (`ce`) and internal timing ticks; halts execution upon receiving the `HLT` signal.
* **Program Counter (`pc.v`):** 4-bit counter storing the address of the next instruction.
* **Memory Address Register & RAM (`memory.v`):** 16x8-bit RAM preloaded with executable code (`program.bin`) via `$readmemh`.
* **Instruction Register (`ir.v`):** Decodes top 4 bits as opcode (`ir[7:4]`) and bottom 4 bits as address operand (`ir[3:0]`).
* **Accumulator & B-Register (`reg_a.v`, `reg_b.v`):** 8-bit general-purpose registers supplying operands to the arithmetic logic unit.
* **Adder/Subtractor (`adder.v`):** 8-bit arithmetic unit handling binary addition and two's complement subtraction.
* **Control Unit (`controller.v`):** Hardwired FSM controller generating a 13-bit microcode control word based on the current opcode and machine state (`T0`–`T5`).
* **Output Register (`out_reg.v`):** Laches execution results for external visualization.

---

## 3. Instruction Set Architecture (ISA) & FSM Cycle

The SAP-1 control unit operates on a 6-state ring sequence ($T_0$ to $T_5$):

| Opcode | Mnemonic | Machine Hex | Operation Description |
| :---: | :---: | :---: | :--- |
| `0000` | **LDA** | `0x0` | Load RAM content at address `M` into Accumulator A |
| `0001` | **ADD** | `0x1` | Add RAM content at address `M` to Accumulator A |
| `0010` | **SUB** | `0x2` | Subtract RAM content at address `M` from Accumulator A |
| `1110` | **OUT** | `0xE` | Load Accumulator A value into Output Register |
| `1111` | **HLT** | `0xF` | Stop machine clock generation |

### Micro-Operation Sequence ($T_0 - T_5$):
- **$T_0$ (Fetch 1):** $PC \rightarrow MAR$
- **$T_1$ (Fetch 2):** $PC \leftarrow PC + 1$
- **$T_2$ (Fetch 3):** $RAM \rightarrow IR$
- **$T_3$ (Execute 1):** Decode Opcode $\rightarrow$ Load Operand address to $MAR$ or trigger execution.
- **$T_4$ (Execute 2):** Read RAM data into Register A or Register B.
- **$T_5$ (Execute 3):** Perform Addition/Subtraction and store result back into Register A.

---

## 4. Directory Structure

```text
├── doc/                        # Architecture diagrams and reports
├── rtl/                        # Synthesizable Verilog HDL files
│   ├── adder.v
│   ├── clock.v
│   ├── controller.v
│   ├── ir.v
│   ├── memory.v
│   ├── out_reg.v
│   ├── pc.v
│   ├── reg_a.v
│   ├── reg_b.v
│   └── sap1_top.v              # Top-level structural module
├── sim/                        # Testbench and simulation scripts
│   ├── program.bin             # Hex machine code binary
│   └── tb_sap1.v               # System testbench file
└── README.md
```

---

## 5. How to Run Simulation

### Using Xilinx Vivado (GUI/TCL):
1. Create a new Vivado RTL project and select target FPGA (e.g., Spartan-3E / Artix-7).
2. Add all `.v` files from `rtl/` into Design Sources.
3. Add `sim/tb_sap1.v` and `sim/program.bin` into Simulation Sources.
4. Run **Behavioral Simulation** and observe waveforms for signal execution.

### Using Icarus Verilog & GTKWave (CLI):
```bash
cd sim/
iverilog -o sap1_sim ../rtl/*.v tb_sap1.v
vvp sap1_sim
gtkwave tb_sap1.vcd
```

---

## 6. Verification & Test Program Results

The binary program (`program.bin`) loaded into memory tests the complete instruction chain:

```text
Address  Machine Code  Assembly Equivalent  Description
0x0      0x0D          LDA 0xD              # Load A with RAM[0xD] (Value: 0x03)
0x1      0x1E          ADD 0xE              # Add RAM[0xE] (Value: 0x04) -> A = 0x07
0x2      0x2F          SUB 0xF              # Sub RAM[0xF] (Value: 0x02) -> A = 0x05
0x3      0xE0          OUT                  # Display A (Output = 0x05)
0x4      0xF0          HLT                  # Halt execution
```

**Result:** The simulation waveform verifies that after $T_3$ of the `OUT` instruction, the output register captures `0x05` ($3 + 4 - 2 = 5$) and the system cleanly enters the halted state.