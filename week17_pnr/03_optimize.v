// ============================================================
//  W17-3：同一個功能三種寫法，比最高時脈
//  重點：★ 這是整份教材的收尾 —— 把第 11、12、13 週學的
//        「面積 / 關鍵路徑 / 管線」放在同一個題目上實測
//
//  題目：把 8 個 8 位元的數字加起來
// ============================================================
`timescale 1ns / 1ps

// ============================================================
//  版本 A：線性串接（最直覺，也最慢）
//
//    d0 + d1 + d2 + d3 + d4 + d5 + d6 + d7
//
//  ★ 加法是【由左往右】結合的，所以這寫法會產生：
//       ((((((d0+d1)+d2)+d3)+d4)+d5)+d6)+d7
//    七層加法器【串成一條】—— 關鍵路徑非常長
// ============================================================
module sum_linear (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  d0, d1, d2, d3, d4, d5, d6, d7,
    output reg  [10:0] sum
);
    reg [7:0] r0,r1,r2,r3,r4,r5,r6,r7;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r0<=0;r1<=0;r2<=0;r3<=0;r4<=0;r5<=0;r6<=0;r7<=0;
        end else begin
            r0<=d0;r1<=d1;r2<=d2;r3<=d3;r4<=d4;r5<=d5;r6<=d6;r7<=d7;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) sum <= 0;
        else        sum <= r0+r1+r2+r3+r4+r5+r6+r7;   // ← 七層串接
    end
endmodule


// ============================================================
//  版本 B：平衡樹（同一拍算完，但排成樹狀）
//
//         d0 d1  d2 d3  d4 d5  d6 d7
//          \ /    \ /    \ /    \ /
//           +      +      +      +      ← 第 1 層
//            \    /        \    /
//             \  /          \  /
//              +              +          ← 第 2 層
//               \            /
//                \          /
//                     +                  ← 第 3 層
//
//  ★ 同樣 7 顆加法器，但深度從 7 層變成 3 層（log2(8)）
//    延遲和吞吐量【完全沒變】，只是把式子重新括號而已
//
//  ⚠️⚠️ 實測結果：這個版本和版本 A【一模一樣快】（都是 109.30 MHz，
//        都是 170 個邏輯單元）。
//
//        因為 Yosys 自己就會把加法鏈重新平衡成樹狀 ——
//        這種等級的最佳化是綜合工具的基本功，不需要你手動做。
//
//        ★ 這正是第 11 週 03_area_compare 講過的道理：
//          「工具做得到的事，手動做只會讓程式碼變難讀」。
//          寫成樹狀【唯一的價值】是【人比較看得懂結構】。
// ============================================================
module sum_tree (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  d0, d1, d2, d3, d4, d5, d6, d7,
    output reg  [10:0] sum
);
    reg [7:0] r0,r1,r2,r3,r4,r5,r6,r7;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r0<=0;r1<=0;r2<=0;r3<=0;r4<=0;r5<=0;r6<=0;r7<=0;
        end else begin
            r0<=d0;r1<=d1;r2<=d2;r3<=d3;r4<=d4;r5<=d5;r6<=d6;r7<=d7;
        end
    end

    //  ★ 差別只在【括號怎麼加】—— 一個字元都沒多，深度少一半
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) sum <= 0;
        else        sum <= ((r0+r1) + (r2+r3)) + ((r4+r5) + (r6+r7));
    end
endmodule


// ============================================================
//  版本 C：管線（第 12 週學的）
//  把樹的三層切開，每層之間插一組正反器
//
//  ★ 延遲從 2 拍變 4 拍，但每一級的路徑只剩【一顆加法器】
//
//  ★★ 實測：230.04 MHz —— 比前兩個版本快【2.1 倍】。
//     而且邏輯單元從 170 降到 141，【更快而且更小】。
//
//     為什麼會更小？因為切開之後每一級的加法器位元數比較窄
//     （級 1 只加 8 位元、級 2 加 9 位元…），
//     不像一次全加要處理到 11 位元。
//
//     ⚠️ 但在 ASIC 上要重新算：多了 23 顆正反器，
//        用第 13 週 tiny_cells.lib 的數字是 23 x 18 = 414 面積單位。
// ============================================================
module sum_pipe (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  d0, d1, d2, d3, d4, d5, d6, d7,
    output reg  [10:0] sum
);
    reg [7:0] r0,r1,r2,r3,r4,r5,r6,r7;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r0<=0;r1<=0;r2<=0;r3<=0;r4<=0;r5<=0;r6<=0;r7<=0;
        end else begin
            r0<=d0;r1<=d1;r2<=d2;r3<=d3;r4<=d4;r5<=d5;r6<=d6;r7<=d7;
        end
    end

    //  ---- 級 1：兩兩相加 ----
    reg [8:0] s1_0, s1_1, s1_2, s1_3;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin s1_0<=0; s1_1<=0; s1_2<=0; s1_3<=0; end
        else begin
            s1_0 <= r0 + r1;
            s1_1 <= r2 + r3;
            s1_2 <= r4 + r5;
            s1_3 <= r6 + r7;
        end
    end

    //  ---- 級 2 ----
    reg [9:0] s2_0, s2_1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin s2_0<=0; s2_1<=0; end
        else begin
            s2_0 <= s1_0 + s1_1;
            s2_1 <= s1_2 + s1_3;
        end
    end

    //  ---- 級 3 ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) sum <= 0;
        else        sum <= s2_0 + s2_1;
    end
endmodule

//  ---- 模擬（確認三種寫法算出來一樣）----
//  iverilog -o sim.out 03_optimize.v 03_optimize_tb.v
//  vvp sim.out
//
//  ---- 實測最高時脈 ----
//  03_optimize.bat
