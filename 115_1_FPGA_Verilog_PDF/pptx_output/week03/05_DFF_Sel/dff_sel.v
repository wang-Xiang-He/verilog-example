`timescale 1ns/1ps

// =====================================================================
// dff_sel：正反器選擇電路（講義第 30、32 頁）
//   da、db 各自經過一個 D 型正反器，再由 sel 選擇輸出哪一個
//   ※ 需要 dff.v、mux2_1.v 一起編譯
// =====================================================================
module dff_sel (da, db, sel, clk, q);
    input  da, db, sel, clk;
    output q;
    wire   qa, qb;

    dff    dff1 (da, clk, qa);                            // 依順序
    dff    dff2 (db, clk, qb);                            // 依順序
    mux2_1 mux  (.ma(qa), .mb(qb), .s(sel), .mout(q));    // 依名稱
endmodule
