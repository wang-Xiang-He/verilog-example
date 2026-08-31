// ============================================================
//  W11-3：同一件事三種寫法，比面積      ← 課本 11.1 資源共用 + 11.4
//  重點：★ 功能一模一樣，面積可以差好幾倍
//        「會寫」和「寫得好」的分界線就在這裡
//
//  每一組都有 A / B 兩個版本，功能完全相同（測試平台會逐一比對），
//  但綜合出來的資源差很多。
// ============================================================
`timescale 1ns / 1ps

// ============================================================
//  第 1 組：資源共用（課本 11.1）★ 本週最重要的一組
//  功能：sel 決定要算 a+b 還是 a+c
// ============================================================

//  ❌ A 版：兩顆加法器，最後用多工器挑一個
//     直覺會這樣寫，但等於「兩邊都算好再丟掉一邊」
module share_bad (
    input  wire [7:0] a, b, c,
    input  wire       sel,
    output wire [8:0] y
);
    wire [8:0] sum_ab = a + b;      // 加法器 1
    wire [8:0] sum_ac = a + c;      // 加法器 2
    assign y = sel ? sum_ab : sum_ac;
endmodule

//  ✅ B 版：先用多工器選運算元，再共用一顆加法器
//     ★ 這就是課本說的「資源共用 Resource Sharing」
module share_good (
    input  wire [7:0] a, b, c,
    input  wire       sel,
    output wire [8:0] y
);
    wire [7:0] operand = sel ? b : c;   // 多工器（便宜）
    assign y = a + operand;              // 只有一顆加法器（貴）
endmodule


// ============================================================
//  第 2 組：乘以常數
//  功能：算 a * 9
// ============================================================

//  ❌ A 版：直接寫乘法
module mul9_bad (
    input  wire [7:0]  a,
    output wire [11:0] y
);
    assign y = a * 9;
endmodule

//  ✅ B 版：9 = 8 + 1，所以 a*9 = (a<<3) + a
//     位移在硬體上是「接線」，不花任何一顆閘
module mul9_good (
    input  wire [7:0]  a,
    output wire [11:0] y
);
    assign y = ({4'b0, a} << 3) + {4'b0, a};
endmodule


// ============================================================
//  第 3 組：★ 反例 —— 你以為會省，其實工具早就幫你做了
//  功能：a 等於 3、7、11、15 其中之一就輸出 1
//
//  實測：兩個版本【都是 3 個 LUT】，一模一樣。
//  Yosys 自己就看穿了那四個比較器可以化簡，不需要你手動優化。
// ============================================================

//  A 版：四個比較器 OR 起來（看起來很浪費）
module match_bad (
    input  wire [7:0] a,
    output wire       hit
);
    assign hit = (a == 8'd3) | (a == 8'd7) | (a == 8'd11) | (a == 8'd15);
endmodule

//  B 版：手動看穿規律 —— 3、7、11、15 的共通點是
//     「低 2 位都是 11 而且高 4 位是 0」
//     ★ 但綜合出來和 A 版【面積完全一樣】。
//       這種等級的化簡是布林最佳化的基本功，工具閉著眼睛都做得到。
module match_good (
    input  wire [7:0] a,
    output wire       hit
);
    assign hit = (a[7:4] == 4'b0000) && (a[1:0] == 2'b11);
endmodule


// ============================================================
//  第 4 組：★ 反例二 —— 換寫法反而變大
//  優先權編碼：if-else 鏈 vs casez
//
//  實測：if-else 版 5 個 LUT，casez 版 6 個 LUT。
//        casez 讀起來比較整齊，但面積【略大一點】。
//  → 可讀性和面積有時是要取捨的，不是換個寫法就一定賺。
// ============================================================
module pri_ifelse (
    input  wire [7:0] d,
    output reg  [2:0] y
);
    always @(*) begin
        if      (d[7]) y = 3'd7;
        else if (d[6]) y = 3'd6;
        else if (d[5]) y = 3'd5;
        else if (d[4]) y = 3'd4;
        else if (d[3]) y = 3'd3;
        else if (d[2]) y = 3'd2;
        else if (d[1]) y = 3'd1;
        else           y = 3'd0;
    end
endmodule

module pri_casez (
    input  wire [7:0] d,
    output reg  [2:0] y
);
    always @(*) begin
        casez (d)
            8'b1???????: y = 3'd7;
            8'b01??????: y = 3'd6;
            8'b001?????: y = 3'd5;
            8'b0001????: y = 3'd4;
            8'b00001???: y = 3'd3;
            8'b000001??: y = 3'd2;
            8'b0000001?: y = 3'd1;
            default:     y = 3'd0;
        endcase
    end
endmodule

//  ---- 模擬（先確認 A/B 功能真的一樣）----
//  iverilog -o sim.out 03_area_compare.v 03_area_compare_tb.v
//  vvp sim.out
//
//  ---- 綜合比面積 ----
//  03_area_compare.bat
