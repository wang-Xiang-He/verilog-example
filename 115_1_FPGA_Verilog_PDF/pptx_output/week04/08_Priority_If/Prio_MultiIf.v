`timescale 1ns/1ps

// =====================================================================
// Prio_MultiIf：多個獨立的 if，後面的蓋掉前面的（講義第 26 頁 範例 2）
//   先給預設值 Result1，再依序檢查 X、Y、Z
//   「最後寫的」優先權最高 → Z 最高，和 Prio_IfElse 功能完全相同
// =====================================================================
module Prio_MultiIf (
    input            X,
    input            Y,
    input            Z,
    input      [3:0] Result1,
    input      [3:0] Result2,
    input      [3:0] Result3,
    input      [3:0] Result4,
    output reg [3:0] Out
);
    always @(*) begin
        Out = Result1;          // 預設值（優先權最低）
        if (X)                  // 優先權 3
            Out = Result2;
        if (Y)                  // 優先權 2
            Out = Result3;
        if (Z)                  // 優先權 1（最高）：最後執行，會蓋掉前面的結果
            Out = Result4;
    end
endmodule
