`timescale 1ns/1ps

// =====================================================================
// gate_delay2：以邏輯閘層描述方式，設定連接線信號轉換延遲（Net Delay，範例練習 7-004，講義第 29~31 頁）
//   電路：y = (a1 & a2) | (a3 & a4)
//     a1 ─┐
//         AND1 ── y1 ─┐
//     a2 ─┘           │
//                     OR1 ── y
//     a3 ─┐           │
//         AND2 ── y2 ─┘
//     a4 ─┘
// =====================================================================
module gate_delay2 (
    input  a1,
    input  a2,
    input  a3,
    input  a4,
    output y
);
    wire #2 y1;                     // 連接線延遲（net delay）：and1 的輸出要再經過 2ns 才到 y1 這條線
    wire    y2;

    and #4  and1 (y1, a1, a2);
    and #6  and2 (y2, a3, a4);
    or  #10 or1  (y,  y1, y2);
endmodule
