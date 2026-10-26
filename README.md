# 8-Bit 5-Stage Pipelined RISC CPU in Verilog

![Language](https://img.shields.io/badge/Language-Verilog--2001-blue.svg)
![Architecture](https://img.shields.io/badge/Architecture-8--bit%20RISC%20Harvard-orange.svg)
![Pipeline](https://img.shields.io/badge/Pipeline-5--Stage-success.svg)
![Target](https://img.shields.io/badge/FPGA-Xilinx%20Vivado%20(100%20MHz)-red.svg)
![Verification](https://img.shields.io/badge/Verification-Self--Checking%20Testbench-brightgreen.svg)

An industry-grade, fully synthesizable **8-bit RISC processor core** featuring a classic **5-stage pipeline (IF, ID, EX, MEM, WB)** implemented from scratch in Verilog HDL. Building upon the foundational concepts of the [4-bit Pipelined RISC CPU](https://github.com/Hudo1501/4bit-pipelined-risc-cpu-verilog), this project scales up the datapath to 8-bit width, expands to a fixed 16-bit Instruction Set Architecture (ISA), and incorporates complete hardware hazard resolution including **data forwarding, write-through register file bypassing, load-use hazard stalling, and branch flushing**.

---

## 📌 Table of Contents
1. [Key Features & Specifications](#-key-features--specifications)
2. [System Overview & File Hierarchy](#-system-overview--file-hierarchy)
3. [Instruction Set Architecture (ISA)](#-instruction-set-architecture-isa)
4. [5-Stage Pipeline Microarchitecture](#-5-stage-pipeline-microarchitecture)
5. [Control Unit & Signal Matrix](#-control-unit--signal-matrix)
6. [Hazard Detection & Resolution](#-hazard-detection--resolution)
7. [Design Decisions & Trade-offs](#-design-decisions--trade-offs)
8. [Vivado Implementation & Simulation Guide](#-vivado-implementation--simulation-guide)
9. [Verification & Performance Metrics](#-verification--performance-metrics)
10. [Author](#-author)

---

## 🚀 Key Features & Specifications

| Parameter | Specification | Description |
| :--- | :--- | :--- |
| **Data Width** | 8 bits | Registers, ALU, and Data Memory operate on 8-bit unsigned/signed integers (`0–255`) |
| **Instruction Width** | 16 bits (Fixed) | Every instruction is encoded as a single 16-bit word |
| **Memory Architecture** | Harvard | Separate Instruction ROM (`256 × 16-bit`) and Data RAM (`256 × 8-bit`) eliminating structural hazards |
| **Register File** | `8 × 8-bit` (`R0`–`R7`) | Dual asynchronous read ports with internal write-through bypass, single synchronous write port (`R0` is a general-purpose register) |
| **Program Counter (PC)** | 8 bits | Addresses up to 256 instructions |
| **Pipeline Stages** | 5 Stages | `IF` (Fetch) $\rightarrow$ `ID` (Decode) $\rightarrow$ `EX` (Execute) $\rightarrow$ `MEM` (Memory) $\rightarrow$ `WB` (Write-Back) |
| **Status Flags** | `Z` (Zero), `C` (Carry/Borrow) | Updated in the `EX` stage by arithmetic, logic, and shift operations |
| **Instruction Set** | 16 Instructions (4-bit Opcode) | Arithmetic, Bitwise Logic, Shifts, Immediate, Load/Store, Unconditional/Conditional Branches, and Halt |
| **Hazard Handling** | Hardware-Resolved | `EX/MEM` & `MEM/WB` Forwarding, Register Bypass, 1-cycle Load-Use Stall, 2-cycle Branch Flush |
| **Target Synthesis** | Xilinx FPGA (Vivado) | Fully synthesizable Verilog-2001 targeting a `100 MHz` (`10 ns`) system clock constraint |

---

## 🏗️ System Overview & File Hierarchy

### Top-Level System Block Diagram
The processor core (`risc8_5stage_core`) is completely self-contained. It requires only two inputs (`clk` and `rst`) and exposes four observation/debug ports (`halted`, `pc_out[7:0]`, `flags_out[1:0]`, and `instr_done`) that can be routed directly to onboard FPGA LEDs or monitored by the self-checking testbench.

![System Block Diagram](Screenshot%202026-10-23%20095025.png)

### RTL File Structure
```text
8bit-5stage-risc-cpu-verilog/
├── design_sources/
│   ├── risc8_5stage_core.v   # Top-level module: PC, 4 pipeline registers, flags, branch/halt logic, interconnects
│   ├── imem.v                # Stage 1 (IF): 256 x 16-bit Instruction Memory (ROM) with built-in verification program
│   ├── control_unit.v        # Stage 2 (ID): Hard-wired combinational opcode decoder generating 14 control signals
│   ├── regfile.v             # Stage 2/5 (ID/WB): 8 x 8-bit Register File (2 read ports + WB bypass, 1 write port)
│   ├── hazard_unit.v         # Stage 2/3 (ID/EX): Combinational data forwarding selector and load-use stall detector
│   ├── alu.v                 # Stage 3 (EX): 8-bit Arithmetic Logic Unit (8 operations) + Z and C flag generation
│   └── dmem.v                # Stage 4 (MEM): 256 x 8-bit Data Memory (RAM) for LD and ST instructions
├── sim_sources/
│   └── tb_risc8_5stage.v     # Self-checking testbench with cycle-by-cycle pipeline trace and automated PASS/FAIL
└── constraints/
    └── risc8.xdc             # Xilinx Design Constraints (100 MHz / 10 ns target clock definition)
