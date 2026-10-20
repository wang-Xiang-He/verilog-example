`timescale 1ns/1ps

// =====================================================================
// Adder16（新版）：用 #( , ) 一次傳兩個參數給 Adder（講義第 12 頁）
//   #(our_size1, our_size2)：依順序，our_size1 → size1、our_size2 → size2
//   ※ 名稱叫 Adder16，但 our_size1 = 8，所以實際上是 8 位元加法器（和講義第 14 頁波形一致）
//   ※ vlog 只要編譯 Adder16.v 和 Adder16_tb.v，Scalable.v 會被 `include 自動帶進來
// =====================================================================
`include "Scalable.v"

module Adder16 #(
    parameter our_size1 = 8,
    parameter our_size2 = 16
) (
    input  [our_size1-1:0] A,
    input  [our_size1-1:0] B,
    input                  Carry_In,
    output [our_size1-1:0] Sum,
    output                 Carry_Out
);
    Adder #(our_size1, our_size2) My_Adder16 (A, B, Carry_In, Sum, Carry_Out);
    // 依名稱的寫法：Adder #(.size1(our_size1), .size2(our_size2)) My_Adder16 (...);
endmodule
