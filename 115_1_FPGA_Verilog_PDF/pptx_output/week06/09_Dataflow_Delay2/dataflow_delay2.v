`timescale 1ns/1ps

// =====================================================================
// dataflow_delay2：以資料流描述方式，只設定輸出端邏輯閘的延遲（範例練習 7-003，講義第 25~28 頁）
//   電路：y = (a1 & a2) | (a3 & a4)
//     a1 ─┐
//         AND1 ── y1 ─┐
//     a2 ─┘           │
//                     OR1 ── y
//     a3 ─┐           │
//         AND2 ── y2 ─┘
//     a4 ─┘
// =====================================================================
module dataflow_delay2 (
    input  a1,
    input  a2,
    input  a3,
    input  a4,
    output y
);
    wire y1, y2;

    assign y1 = a1 & a2;            // 沒有延遲：輸入一變 y1 立刻變
    assign y2 = a3 & a4;
    assign #16 y = y1 | y2;         // 延遲全部集中在最後一級：16ns
endmodule
