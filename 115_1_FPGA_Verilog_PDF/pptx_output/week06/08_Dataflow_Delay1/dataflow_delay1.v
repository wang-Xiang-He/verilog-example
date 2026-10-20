`timescale 1ns/1ps

// =====================================================================
// dataflow_delay1：以資料流描述方式，設定個別邏輯閘的延遲（範例練習 7-002，講義第 23、24 頁）
//   電路：y = (a1 & a2) | (a3 & a4)
//     a1 ─┐
//         AND1 ── y1 ─┐
//     a2 ─┘           │
//                     OR1 ── y
//     a3 ─┐           │
//         AND2 ── y2 ─┘
//     a4 ─┘
// =====================================================================
module dataflow_delay1 (
    input  a1,
    input  a2,
    input  a3,
    input  a4,
    output y
);
    wire y1, y2;

    // assign #延遲 目標 = 運算式;   運算式的結果在 #延遲 之後才指定給目標
    assign #4  y1 = a1 & a2;
    assign #6  y2 = a3 & a4;
    assign #10 y  = y1 | y2;
endmodule
