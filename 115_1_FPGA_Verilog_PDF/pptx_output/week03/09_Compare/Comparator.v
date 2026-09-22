`timescale 1ns/1ps

// =====================================================================
// Comparator：比較 a、b 的大小
//   larger = (a > b)、equal = (a == b)、less = (a < b)
// =====================================================================
module Comparator (a, b, larger, equal, less);
    parameter size = 8;
    input  [size-1:0] a, b;
    output            larger, equal, less;
    wire              larger, equal, less;

    assign larger = (a >  b);   // 關係運算子（Relational）
    assign equal  = (a == b);   // 等式運算子（Equality）
    assign less   = (a <  b);
endmodule
