`timescale 1ns/1ps

// =====================================================================
// DeMux1X2_1：1 對 2 解多工器，範例 1：使用 assign 敘述（講義第 44、45 頁）
//   布林方程式：Y0 = Select'．D、Y1 = Select．D
//   Select = 0 → D 送到 Y0；Select = 1 → D 送到 Y1；沒被選到的輸出是 0
// =====================================================================
module DeMux1X2_1 (
    input  D,
    input  Select,
    output Y0,
    output Y1
);
    assign Y0 = (!Select) & D;
    assign Y1 = Select & D;
endmodule
