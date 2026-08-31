// ============================================================
//  W3-9：比較器 (Comparator)          ← 課本 8.1.6
//  重點：★ 有號和無號的比較器是【兩顆不同的電路】，選錯直接判反
// ============================================================
`timescale 1ns / 1ps

module comparator (
    input  wire [7:0] a, b,

    // ---- 無號比較 ----
    output wire u_gt, u_eq, u_lt,

    // ---- 有號比較（同樣的位元，換個解讀）----
    output wire s_gt, s_eq, s_lt,

    // ---- 用減法做比較：課本的作法 ----
    //      a-b 多算一位當借位 (borrow)，借位就告訴你誰大
    output wire [8:0] diff,
    output wire       borrow,

    // ---- 只比是不是相等：XOR + 縮減 OR，比減法器便宜得多 ----
    output wire       eq_cheap
);

    //  直接用比較運算子（課本 4.2.2 說這些都可以合成）
    assign u_gt = (a >  b);
    assign u_eq = (a == b);
    assign u_lt = (a <  b);

    //  $signed() 把同一組位元當有號數再比一次
    assign s_gt = ($signed(a) >  $signed(b));
    assign s_eq = ($signed(a) == $signed(b));
    assign s_lt = ($signed(a) <  $signed(b));

    //  減法版：兩邊都補一個 0 變 9 位元再相減
    //  a >= b 時最高位 = 0，a < b 時最高位 = 1（借位）
    assign diff   = {1'b0, a} - {1'b0, b};
    assign borrow = diff[8];

    //  ★ 只判斷相等的話，不需要減法器：
    //    a^b 逐位比對，全 0 就代表一樣；再用縮減 OR 壓成一位取反
    assign eq_cheap = ~|(a ^ b);

endmodule

//  iverilog -o sim.out 09_comparator.v 09_comparator_tb.v
//  vvp sim.out
//  gtkwave 09_comparator.gtkw
