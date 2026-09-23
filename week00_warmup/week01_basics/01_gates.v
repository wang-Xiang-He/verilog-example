// ============================================================
//  第 1 週 範例 1：四個基本邏輯閘
//  重點：module / 腳位 / assign 連續指定
// ============================================================
`timescale 1ns / 1ps

module gates (
    input  wire a,          // 輸入 a
    input  wire b,          // 輸入 b
    output wire y_and,      // a AND b
    output wire y_or,       // a OR  b
    output wire y_not_a,    // NOT a
    output wire y_xor       // a XOR b
);

    // assign = 「連續指定」，右邊只要一變，左邊立刻跟著變
    // 這就是「組合邏輯」：沒有記憶、沒有時脈、隨時反應
    assign y_and   = a & b;     // &  = AND
    assign y_or    = a | b;     // |  = OR
    assign y_not_a = ~a;        // ~  = NOT
    assign y_xor   = a ^ b;     // ^  = XOR（不一樣才是 1）

endmodule
