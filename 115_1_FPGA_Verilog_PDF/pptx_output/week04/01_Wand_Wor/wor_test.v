`timescale 1ns/1ps

// =====================================================================
// wor_test：Wired-OR（講義第 5、6 頁）
//   同一條 wor 線被兩個 assign 同時驅動 → 結果是兩個驅動值做 OR
//   對應到 ECL（Emitter Coupled Logic）電路把輸出接在一起的行為
// =====================================================================
module wor_test (
    input      a,
    input      b,
    output wor c       // 講義：output c;  wor c;  分兩行宣告
);
    assign c = a;
    assign c = b;      // c = a | b
endmodule
