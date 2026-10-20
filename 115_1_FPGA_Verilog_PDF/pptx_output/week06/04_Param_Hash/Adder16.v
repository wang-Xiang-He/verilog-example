`timescale 1ns/1ps

// =====================================================================
// Adder16：使用 '#' 敘述去取代（overriding）parameter 值，來達到擴充 Adder 這個具有易於調整性的模組
//   （講義第 9 頁）
//   ※ vlog 只要編譯 Adder16.v 和 Adder16_tb.v，Scalable.v 會被 `include 自動帶進來
// =====================================================================
`include "Scalable.v"       // 引用 Scalable.v，一個具有易於調整性的 Adder

module Adder16 #(
    parameter our_size = 16         // 定義為 16 個位元
) (
    input  [our_size-1:0] A,
    input  [our_size-1:0] B,
    input                 Carry_In,
    output [our_size-1:0] Sum,
    output                Carry_Out
);
    // 模組名稱 #(參數值) 實例名稱 (...);
    //   our_size 將會改寫在 My_Adder16 這個 Adder 別名中的 size 值
    //   依順序（by order）：第 1 個值給 Adder 的第 1 個參數 size
    Adder #(our_size) My_Adder16 (A, B, Carry_In, Sum, Carry_Out);

    // 依名稱（by name，Verilog-2001）的寫法，效果相同，參數多的時候比較不會給錯：
    //   Adder #(.size(our_size)) My_Adder16 (A, B, Carry_In, Sum, Carry_Out);
endmodule
