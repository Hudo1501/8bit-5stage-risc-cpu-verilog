// =====================================================================
//  FILE        : tb/tb_dump.v
//  MODULE      : tb_dump   (TESTBENCH for random regression testing)
//  PROJECT     : 8-bit RISC Processor Core with 5-Stage Pipeline
// ---------------------------------------------------------------------
//  WHAT THIS FILE DOES
//    Runs whatever program is in program.hex, waits for HLT, then
//    writes the final state (8 registers, flags, all 256 bytes of data
//    memory) to the text file "dump.txt".
//    It does no checking itself: sw/random_test.py compares dump.txt
//    with the answer from the golden model sw/iss.py.
//
//  MODULES CALLED (instantiated) IN THIS FILE
//    risc8_5stage_core  from rtl/risc8_5stage_core.v  -> instance "dut"
//
//  INTERNAL SIGNALS READ
//    dut.u_rf.r[...]      -> rtl/regfile.v
//    dut.u_dmem.mem[...]  -> rtl/dmem.v
//
//  WHO RUNS THIS FILE
//    sw/random_test.py compiles it with iverilog and runs it with vvp.
// =====================================================================

`timescale 1ns/1ps

`ifndef STUDENT_NAME
`define STUDENT_NAME "Truong Dong Hung"
`endif
`ifndef STUDENT_ID
`define STUDENT_ID   "SE201121"
`endif

module tb_dump;
    reg clk = 0, rst = 1;
    wire halted;
    wire [7:0] pc;
    wire [1:0] flags;        // {Z, C}
    wire       instr_done;
    integer f, i;
    integer retired = 0;     // instructions completed (from instr_done)

    always @(posedge clk) if (instr_done) retired <= retired + 1;

    // CALL: module risc8_5stage_core from rtl/risc8_5stage_core.v
    risc8_5stage_core #(.IMEM_FILE("program.mem")) dut (
        .clk(clk), .rst(rst), .halted(halted), .pc_out(pc),
        .flags_out(flags), .instr_done(instr_done));

    initial forever #5 clk = ~clk;   // 100 MHz clock

    initial begin
        // Hi?n th? thông tin sinh viên khi b?t ??u testbench h?i quy
        $display("\n============================================================");
        $display(" tb_dump - Regression Testbench (Golden Model Compare)");
        $display(" Student : %0s      Roll No : %0s", `STUDENT_NAME, `STUDENT_ID);
        $display("============================================================\n");

        #22 rst = 0;
        wait (halted);
        @(posedge clk);
        f = $fopen("dump.txt", "w");                 // open output file
        for (i = 0; i < 8; i = i + 1)
            $fwrite(f, "%02h\n", dut.u_rf.r[i]);     // R0..R7
        $fwrite(f, "%0d %0d\n", flags[1], flags[0]);   // Z C
        for (i = 0; i < 256; i = i + 1)
            $fwrite(f, "%02h\n", dut.u_dmem.mem[i]); // memory
        $fclose(f);

        $display("halted at PC=%02h after %0d instructions", pc, retired);
        $display("Student : %0s | Roll No : %0s | Architectural dump complete.", `STUDENT_NAME, `STUDENT_ID);
        $finish;
    end

    // Watchdog: if the CPU hangs, finish without writing dump.txt
    initial begin #200000 $display("TIMEOUT"); $finish; end
endmodule
