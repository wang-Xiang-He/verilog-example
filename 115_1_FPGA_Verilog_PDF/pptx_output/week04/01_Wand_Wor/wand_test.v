`timescale 1ns/1ps

// =====================================================================
// wand_test：Wired-AND（講義第 3、4 頁）
//   同一條 wand 線被兩個 assign 同時驅動 → 結果是兩個驅動值做 AND
//   對應到開集極（open collector）電路把輸出接在一起的行為
// =====================================================================
module wand_test (
    input       a,
    input       b,
    output wand c      // 講義：output c;  wand c;  分兩行宣告
);
    assign c = a;      // 第 1 個驅動源
    assign c = b;      // 第 2 個驅動源 → c = a & b
endmodule
