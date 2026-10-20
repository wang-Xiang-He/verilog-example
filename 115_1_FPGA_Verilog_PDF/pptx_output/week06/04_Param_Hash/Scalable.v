`timescale 1ns/1ps

// =====================================================================
// Scalable.v：建立一個具有易於調整性（寬度可改）的加法器 Adder（講義第 6 頁）
//   這個檔案會被 Adder16.v 用 `include 引入，vlog 的檔案清單【不要】再列它
// =====================================================================
module Adder #(
    parameter size = 1              // 宣告一個名為 size 的 parameter，且等於 1
) (
    input  [size-1:0] A,            // A 和 B 也使用了名為 size 的參數
    input  [size-1:0] B,
    input             Carry_In,
    output [size-1:0] Sum,          // size = 1 時，[size-1:0] 和 [1-1:0]、[0:0] 是相等的（1 位元）
    output            Carry_Out
);
    assign {Carry_Out, Sum} = A + B + Carry_In;
endmodule
