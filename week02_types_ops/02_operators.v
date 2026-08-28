// ============================================================
//  W2-2：運算子大集合
//  重點：Verilog 的運算子分成五類，用途完全不同
// ============================================================
`timescale 1ns / 1ps

module operators (
    input  wire [3:0] a,
    input  wire [3:0] b,
    // --- 算術 ---
    output wire [4:0] o_add,     // 5 位元才裝得下進位
    output wire [4:0] o_sub,
    output wire [7:0] o_mul,
    // --- 位元運算（一位一位做）---
    output wire [3:0] o_and,
    output wire [3:0] o_or,
    output wire [3:0] o_xor,
    output wire [3:0] o_not,
    // --- 邏輯運算（整體當一個真假值）---
    output wire       o_land,    // && 
    output wire       o_lnot,    // !
    // --- 關係 ---
    output wire       o_eq,      // ==
    output wire       o_lt,      // <
    // --- 縮減（把一整條線縮成一個位元）---
    output wire       o_red_and, // &a  所有位都是 1 才 1
    output wire       o_red_or,  // |a  任一位是 1 就 1
    output wire       o_red_xor, // ^a  奇偶檢查
    // --- 位移 ---
    output wire [3:0] o_shl,
    output wire [3:0] o_shr
);

    assign o_add     = a + b;
    assign o_sub     = a - b;
    assign o_mul     = a * b;

    assign o_and     = a & b;      // 位元 AND：4 個 AND 閘
    assign o_or      = a | b;
    assign o_xor     = a ^ b;
    assign o_not     = ~a;

    assign o_land    = a && b;     // 邏輯 AND：a 非零 而且 b 非零 → 1
    assign o_lnot    = !a;         // a 是 0 → 1

    assign o_eq      = (a == b);
    assign o_lt      = (a <  b);

    assign o_red_and = &a;         // 縮減：a[3]&a[2]&a[1]&a[0]
    assign o_red_or  = |a;
    assign o_red_xor = ^a;         // 1 的個數是奇數 → 1

    assign o_shl     = a << 1;     // 左移一位 = 乘 2
    assign o_shr     = a >> 1;     // 右移一位 = 除 2

endmodule
