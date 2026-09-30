`timescale 1ns/1ps

// =====================================================================
// Zero_Detect：sum 為 0 時 zero = 1，否則 zero = 0（講義第 7 頁）
//   zero 在 always 裡被賦值 → 必須宣告成 reg
// =====================================================================
module Zero_Detect (
    input      [3:0] sum,
    output reg       zero
);
    always @(*) begin          // 講義：always @(sum)
        if (sum == 0)          // 如果 sum = 0
            zero = 1;          // 則 zero 設為 1
        else
            zero = 0;          // 否則 zero 設為 0
    end
endmodule
