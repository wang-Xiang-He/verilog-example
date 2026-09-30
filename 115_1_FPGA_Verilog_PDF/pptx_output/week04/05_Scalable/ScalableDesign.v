`timescale 1ns/1ps

// =====================================================================
// ScalableDesign：c = a & b，位元寬度由 parameter width 決定（講義第 17 頁）
//   要改成 4 位元，只要改 width 一個地方（或實例化時覆寫）
// =====================================================================
module ScalableDesign #(
    parameter width = 16
) (
    input  [width-1:0] a,
    input  [width-1:0] b,
    output [width-1:0] c
);
    assign c = a & b;
endmodule
