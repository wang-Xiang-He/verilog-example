`timescale 1ns/1ps

// =====================================================================
// Scalable.v（新版）：有兩個參數的 Adder（講義第 11 頁）
//   size1：A、B、Sum 的寬度
//   size2：這個電路沒有用到，只是用來示範「一次傳好幾個參數」
//   這個檔案會被 Adder16.v 用 `include 引入，vlog 的檔案清單【不要】再列它
// =====================================================================
module Adder #(
    parameter size1 = 1,            // 宣告一個名為 size1 的 parameter，且等於 1
    parameter size2 = 2             // 第 2 個參數（多個參數之間用逗號分開）
) (
    input  [size1-1:0] A,           // A 和 B 使用了名為 size1 的參數
    input  [size1-1:0] B,
    input              Carry_In,
    output [size1-1:0] Sum,
    output             Carry_Out
);
    assign {Carry_Out, Sum} = A + B + Carry_In;
    // ※ 講義第 11 頁另外寫了 wire [size1-1:0] sum;（小寫 s）：Verilog 大小寫有別，
    //   sum 和 Sum 是兩條不同的線，而且 sum 沒有被用到。ANSI 寫法不需要再宣告 wire，這行就拿掉了
endmodule
