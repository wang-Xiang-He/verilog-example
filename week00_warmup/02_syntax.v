// ============================================================
//  W0-2：語法練習場
//  專門示範「數字寫法 / 大括號 {} / for 迴圈」這三個 Python 人最容易卡的
// ============================================================
`timescale 1ns / 1ps

module syntax_demo (
    input  wire [7:0] a,
    input  wire [7:0] b,

    // ---- 大括號 {} 的四種用法 ----
    output wire [15:0] joined,     // {a, b}        接在一起
    output wire [15:0] repeated,   // {2{a}}        複製兩次
    output wire [7:0]  reversed,   // {a[0],a[1]…}  前後顛倒
    output wire [7:0]  mixed,      // 夾常數進去

    // ---- for 迴圈算出來的 ----
    output wire [3:0]  ones,       // a 裡面有幾個 1
    output wire [7:0]  reversed_f, // 用 for 顛倒（跟上面結果一樣）

    // ---- 常數的各種寫法 ----
    output wire [7:0]  const_bin,
    output wire [7:0]  const_hex,
    output wire [7:0]  const_dec
);

    // ================= 大括號 {} =================
    //  ★ Python 的 {} 是 dict / set
    //  ★ Verilog 的 {} 是「把好幾條線黏成一條」
    assign joined   = {a, b};                 // 8 位 + 8 位 = 16 位
    assign repeated = {2{a}};                 // 等同 {a, a}
    assign reversed = {a[0], a[1], a[2], a[3],
                       a[4], a[5], a[6], a[7]};
    assign mixed    = {a[7:4], 4'b1010};      // 取 a 的高 4 位，後面接常數

    // ================= for 迴圈 =================
    //  ★ Python 的 for 是「跑 N 次」
    //  ★ Verilog 的 for 是「複製 N 份硬體」串成一條鏈，一個時脈之內走完
    //    （不是同時算 —— 後面那個要等前面的結果，但不需要多個時脈）
    function [3:0] count_ones;
        input [7:0] x;
        integer i;                            // 迴圈變數要宣告成 integer
        begin
            count_ones = 0;
            for (i = 0; i < 8; i = i + 1)     // 沒有 range()，要自己寫三段
                count_ones = count_ones + x[i];
        end
    endfunction

    function [7:0] reverse_bits;
        input [7:0] x;
        integer i;
        begin
            for (i = 0; i < 8; i = i + 1)
                reverse_bits[i] = x[7-i];
        end
    endfunction

    assign ones       = count_ones(a);
    assign reversed_f = reverse_bits(a);

    // ================= 常數寫法 =================
    assign const_bin = 8'b1010_0101;          // 底線只是給人看的
    assign const_hex = 8'hA5;
    assign const_dec = 8'd165;                // 三個都是同一個值

endmodule
