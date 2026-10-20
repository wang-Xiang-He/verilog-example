`timescale 1ns/1ps

// =====================================================================
// Mux2to1_2：2 對 1 多工器，第 2 種寫法：assign + 條件運算子（講義第 31、32 頁）
//   Select = 1 則 Out = a，Select = 0 則 Out = b
// =====================================================================
module Mux2to1_2 (
    input  a,
    input  b,
    input  Select,
    output Out                  // assign 指令可使用 wire 型態，不可使用 reg 型態
);
    assign Out = Select ? a : b;
endmodule
