`timescale 1ns/1ps

// =====================================================================
// Casex_Prio：casex + 不在乎位元 x（講義第 32 頁 範例 4）
//   把 X、Y、Z 接成 3 位元 temp，再用 1xx / x1x / xx1 比對
//   項目中的 x 代表「這個位元是 0 或 1 都算符合」
//   多個項目同時符合時，case 取「第一個」符合的 → X 優先權最高
// =====================================================================
module Casex_Prio (
    input            X,
    input            Y,
    input            Z,
    input      [3:0] Result1,
    input      [3:0] Result2,
    input      [3:0] Result3,
    input      [3:0] Result4,
    output reg [3:0] Value
);
    reg [2:0] temp;

    always @(*) begin           // 講義：always @(X or Y or Z)
        temp = {X, Y, Z};
        casex (temp)            // synopsys parallel_case
            3'b1xx  : Value = Result1;   // X = 1
            3'bx1x  : Value = Result2;   // Y = 1
            3'bxx1  : Value = Result3;   // Z = 1
            default : Value = Result4;   // 000
        endcase
    end
endmodule
