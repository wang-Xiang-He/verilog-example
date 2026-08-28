// ============================================================
//  W7-2：毛刺 glitch —— 組合邏輯的暫態錯誤
//  重點：★ 訊號在「路上」延遲不一致，會產生一瞬間的錯誤值 ★
// ============================================================
`timescale 1ns / 100ps

module glitch_demo (
    input  wire a,
    output wire y_ideal,      // 理論上永遠是 1
    output wire y_real        // 實際上會閃一下 0
);

    //  y = a | ~a   數學上永遠是 1
    //  但 ~a 這條路要多走一顆反相器（延遲 2ns），
    //  所以 a 從 1 變 0 的瞬間：
    //     a  已經變 0 了
    //     ~a 還沒變成 1（還在路上）
    //  → 這 2ns 之內 y = 0 | 0 = 0   ← 毛刺！

    wire not_a_ideal, not_a_real;

    assign not_a_ideal = ~a;
    assign y_ideal     = a | not_a_ideal;

    assign #2 not_a_real = ~a;             // 反相器延遲 2ns
    assign #1 y_real     = a | not_a_real; // OR 閘延遲 1ns

endmodule
