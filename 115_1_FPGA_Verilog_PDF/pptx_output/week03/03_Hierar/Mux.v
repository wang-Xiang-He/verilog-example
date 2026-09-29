`timescale 1ns/1ps

// =====================================================================
// Mux：8 位元 2 對 1 多工器（Multiplexer）
//   Sel = 1 → out = a；Sel = 0 → out = b
// =====================================================================
// 埠宣告用 Verilog-2001 的 ANSI 寫法：方向、型態、寬度直接寫在埠列表裡
//   （講義是 Verilog-1995 舊寫法：先列埠名，再到下面分別宣告 input / output / wire）
module Mux (
    input        Sel,
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] out
);
    assign out = Sel ? a : b;       // 條件運算子 ? :
endmodule
