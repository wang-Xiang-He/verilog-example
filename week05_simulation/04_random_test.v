// ============================================================
//  W5-4：待測物 —— 一個「有 bug」的比較器
//  ★ 這個設計故意藏了一個 bug，看亂數測試能不能抓到 ★
// ============================================================
`timescale 1ns / 1ps

module comparator (
    input  wire [7:0] a, b,
    output wire       gt,     // a > b
    output wire       eq,     // a == b
    output wire       lt      // a < b
);

    assign gt = (a > b);
    assign eq = (a == b);

    //  ★ 這裡有 bug：寫成 (a <= b) 了，應該是 (a < b)
    //     只有在 a == b 的時候才會出錯 —— 窮舉測 8 位元要 65536 組，
    //     但亂數測試很快就會撞到
    assign lt = (a <= b);

endmodule
