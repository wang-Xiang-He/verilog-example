// ============================================================
//  第 1 週 範例 3：全加器 Full Adder
//  重點：★ 實例化 ★ —— 用小零件組出大零件
// ============================================================
`timescale 1ns / 1ps

// ---------- 子零件：半加器（跟範例 2 一樣） ----------
module ha (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule


// ---------- 主零件：全加器 ----------
//
//  半加器只能加兩個數。但實際做多位元加法時，
//  低位可能傳一個「進位」上來，所以要能加三個數：a + b + cin
//
//  作法：用兩顆半加器接起來
//
//        a ──┐
//            ├─[ ha1 ]─── s1 ──┐
//        b ──┘        └─ c1    ├─[ ha2 ]─── sum
//                              │        └─ c2
//      cin ────────────────────┘             │
//                                            │
//        c1 ──────────── OR ─────────────── cout
//        c2 ──────────────┘
//
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,        // 低位進來的進位
    output wire sum,
    output wire cout        // 送給高位的進位
);

    wire s1, c1, c2;        // 內部接線（不對外，所以不在腳位列表裡）

    // 第一顆半加器：先算 a + b
    ha ha1 (
        .a     (a),
        .b     (b),
        .sum   (s1),
        .carry (c1)
    );

    // 第二顆半加器：把上面的結果再加 cin
    ha ha2 (
        .a     (s1),
        .b     (cin),
        .sum   (sum),
        .carry (c2)
    );

    // 兩顆之中只要有任何一顆進位，就要往高位進位
    assign cout = c1 | c2;

endmodule
