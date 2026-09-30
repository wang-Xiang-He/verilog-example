`timescale 1ns/1ps

// =====================================================================
// Case_Prio：用 case 寫出有優先權的電路（講義第 31 頁 範例 1）
//   case 的「運算式」是常數 2'b11，「項目」反而是變數 u、v、w
//   → 由上往下找第一個等於 2'b11 的變數，所以 u 優先權最高
//   和講義第 31 頁 範例 2 的 if ... else 寫法功能相同
// =====================================================================
module Case_Prio (
    input      [1:0] u,
    input      [1:0] v,
    input      [1:0] w,
    output reg [2:0] Out
);
    always @(*) begin           // 講義：always @(u or v or w)
        case (2'b11)
            u       : Out = 3'b001;    // 優先權最高
            v       : Out = 3'b010;
            w       : Out = 3'b100;    // 優先權最低
            default : Out = 3'b000;    // u、v、w 都不是 11
        endcase
    end
endmodule
