`timescale 1ns/1ps

// =====================================================================
// Adder8：使用 defparam 敘述去取代（overriding）parameter 值（講義第 7 頁）
//   Adder 預設 size = 1（1 位元），在這裡用 defparam 改成 8 位元
//   ※ vlog 只要編譯 Adder8.v 和 Adder8_tb.v，Scalable.v 會被 `include 自動帶進來
// =====================================================================
`include "Scalable.v"       // 引用 Scalable.v，一個具有易於調整性的 Adder

module Adder8 #(
    parameter our_size = 8          // 定義為 8 個位元
) (
    input  [our_size-1:0] A,
    input  [our_size-1:0] B,
    input                 Carry_In,
    output [our_size-1:0] Sum,
    output                Carry_Out
);
    Adder My_Adder8 (A, B, Carry_In, Sum, Carry_Out);   // My_Adder8 是這個 Adder 的實例名稱（別名）

    // defparam 實例名稱.參數名稱 = 新的值;
    //   把 My_Adder8 這個 Adder 別名中的 size 值改寫成 8
    defparam My_Adder8.size = 8;    // 定義為 8 個位元（講義寫死 8；寫成 = our_size 就會跟著 Adder8 一起變）
endmodule
