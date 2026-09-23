// ============================================================
//  第 1 週 範例 2：半加器 Half Adder
//  重點：用邏輯閘組出「會算數學」的電路
// ============================================================
`timescale 1ns / 1ps

//  真值表：
//     a  b  |  carry  sum      十進位
//     0  0  |    0     0    →   0
//     0  1  |    0     1    →   1
//     1  0  |    0     1    →   1
//     1  1  |    1     0    →   2   （進位！）
//
//  看出來了嗎？sum 就是 XOR，carry 就是 AND。
//  「加法」不是什麼神奇的東西，就是兩個閘。

module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,        // 本位
    output wire carry       // 進位
);

    assign sum   = a ^ b;   // 不一樣 → 1
    assign carry = a & b;   // 都是 1 → 進位

endmodule
