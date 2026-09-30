`timescale 1ns/1ps

// =====================================================================
// Prio_IfElse：巢狀 if ... else 產生優先權（講義第 25 頁 範例 1）
//   Z 優先權最高 → Y → X → 都不成立時輸出 Result1
//   合成結果是 Priority Decoder（一串依序比較的多工器）
// =====================================================================
module Prio_IfElse (
    input            X,
    input            Y,
    input            Z,
    input      [3:0] Result1,
    input      [3:0] Result2,
    input      [3:0] Result3,
    input      [3:0] Result4,
    output reg [3:0] Out
);
    always @(*) begin           // 講義：always @(X or Y or Z)，漏了 Result1~4，見說明
        if (Z)                  // 優先權 1（最高）
            Out = Result4;
        else if (Y)             // 優先權 2
            Out = Result3;
        else if (X)             // 優先權 3
            Out = Result2;
        else                    // 優先權最低
            Out = Result1;
    end
endmodule
