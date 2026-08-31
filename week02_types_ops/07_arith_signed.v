// ============================================================
//  W2-7：有號數 vs 無號數的運算      ← 課本第 7 章 7.4 / 7.5
//  重點：★ 同樣的 8 個位元，宣告成 signed 和不宣告，結果完全不同
//        位元本身沒有「正負」，正負是「你叫工具怎麼解讀它」
// ============================================================
`timescale 1ns / 1ps

module arith_signed (
    input  wire signed [7:0] sa, sb,    // 有號：-128 ~ +127
    input  wire        [7:0] ua, ub,    // 無號：   0 ~  255

    // ---- 加減法：結果的「位元圖案」其實一模一樣 ----
    output wire signed [8:0] s_add,
    output wire        [8:0] u_add,

    // ---- 乘法：這裡才真的看得出差別 ----
    output wire signed [15:0] s_mul,
    output wire        [15:0] u_mul,

    // ---- 除法 ----
    output wire signed [7:0] s_div,
    output wire        [7:0] u_div,

    // ---- 右移：算術右移 >>> 補符號位，邏輯右移 >> 補 0 ----
    output wire signed [7:0] sar,
    output wire        [7:0] shr,

    // ---- 比較：同一組位元，比出來的大小相反 ----
    output wire s_lt,
    output wire u_lt,

    // ---- $signed / $unsigned：臨時改變解讀方式 ----
    output wire signed [8:0] cast_s,
    output wire        [8:0] cast_u
);

    //  加減法：無號 240 + 8 = 248，有號 -16 + 8 = -8
    //  248 的 9 位元是 0_1111_1000，-8 的 9 位元是 1_1111_1000
    //  低 8 位一樣是 1111_1000 —— 差別只在第 9 位怎麼補
    assign s_add = sa + sb;
    assign u_add = ua + ub;

    //  ★ 乘法一定要看清楚：有號乘法會先做符號延伸再乘
    assign s_mul = sa * sb;
    assign u_mul = ua * ub;

    //  除法：除數為 0 時硬體會出 x，這裡先擋掉
    assign s_div = (sb != 0) ? sa / sb : 8'sd0;
    assign u_div = (ub != 0) ? ua / ub : 8'd0;

    //  ★ >>> 只有在「被移的東西是 signed」時才會補符號位
    assign sar = sa >>> 1;      // -16 >>> 1 = -8
    assign shr = ua >>  1;      // 240 >>  1 = 120

    //  比較運算子也會看 signed
    assign s_lt = (sa < sb);    // -16 < 8  → 1
    assign u_lt = (ua < ub);    // 240 < 8  → 0

    //  $signed / $unsigned：把同一堆位元換個身分再算
    assign cast_s = $signed(ua)   + sb;   // 把 ua 當有號數看
    assign cast_u = $unsigned(sa) + ub;   // 把 sa 當無號數看

endmodule

//  ---- 四行指令 ----
//  iverilog -o sim.out 07_arith_signed.v 07_arith_signed_tb.v
//  echo %ERRORLEVEL%
//  vvp sim.out
//  gtkwave 07_arith_signed.gtkw
