`timescale 1ns/1ps

// =====================================================================
// And3_Level：Case I 位準觸發（講義第 19 頁）
//   a、b、c 任一個改變就重新計算 → 合成為純組合邏輯（一個 3 輸入 AND 閘）
// =====================================================================
module And3_Level (
    input      a,
    input      b,
    input      c,
    output reg f
);
    always @(*)            // 講義：always @(a or b or c)
        f = a & b & c;
endmodule
