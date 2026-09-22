`timescale 1ns/1ps

// =====================================================================
// Mux：8 位元 2 對 1 多工器（Multiplexer）
//   Sel = 1 → out = a；Sel = 0 → out = b
// =====================================================================
module Mux (Sel, a, b, out);        // 講義使用 Verilog-1995 的舊式埠宣告：先列埠名，再宣告方向
    input        Sel;
    input  [7:0] a, b;
    output [7:0] out;
    wire   [7:0] out;

    assign out = Sel ? a : b;       // 條件運算子 ? :
endmodule
