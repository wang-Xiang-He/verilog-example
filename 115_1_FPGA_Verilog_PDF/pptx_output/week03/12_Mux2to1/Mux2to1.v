`timescale 1ns/1ps

// =====================================================================
// Mux2to1：2 對 1 多工器（Multiplexer）
//   若 Select = 1，則 Out = a；否則 Out = b
// =====================================================================
module Mux2to1 (a, b, Select, Out);
    input  a, b, Select;
    output Out;
    wire   Out;

    assign Out = Select ? a : b;   // 條件運算子：條件 ? 成立時的值 : 不成立時的值
endmodule
