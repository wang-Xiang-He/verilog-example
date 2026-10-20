`timescale 1ns/1ps

// =====================================================================
// DeMux1X4_1：1 對 4 解多工器，範例 1：使用 assign 敘述（講義第 49、50 頁）
//   布林方程式：Y0 = S1'．S0'．D、Y1 = S1'．S0．D、Y2 = S1．S0'．D、Y3 = S1．S0．D
// =====================================================================
module DeMux1X4_1 (
    input  D,
    input  S1, S0,
    output Y0, Y1, Y2, Y3
);
    assign Y0 = (!S1) & (!S0) & D;
    assign Y1 = (!S1) &   S0  & D;
    assign Y2 =   S1  & (!S0) & D;
    assign Y3 =   S1  &   S0  & D;
endmodule
