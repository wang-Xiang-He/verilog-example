// ============================================================
//  W7-4：★★ 閘級模擬 ★★  本週重頭戲
//
//  同一個設計，兩種模擬：
//    logic_rtl   ── 你寫的 RTL（功能模擬，零延遲，乾乾淨淨）
//    logic_gate  ── Yosys 綜合出來的真實 iCE40 網表（含原廠時序）
//
//  一起跑，把波形疊在一起看，你會看到真實電路的樣子。
// ============================================================
`timescale 1ns / 1ps

// ---------- 你寫的 RTL ----------
module logic_rtl (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [8:0] sum,
    output wire       big
);
    assign sum = a + b;
    assign big = (sum > 9'd200);
endmodule


// ---------- Yosys 綜合出來的閘級網表 ----------
//  這個檔是 synth.bat 產生的，裡面全是 SB_LUT4 / SB_CARRY 之類的
//  iCE40 實體元件。搭配 -gspecify -DICE40_HX，
//  iverilog 會套用 Lattice 原廠的真實延遲數字。
`include "04_netlist_syn.v"


// ---------- iCE40 元件的模擬模型（Yosys 附的）----------
`include "_ice40_cells_sim.v"
