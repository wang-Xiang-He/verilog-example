`timescale 1ns/1ps

// =====================================================================
// Func_AS：加法、減法、加 1、減 1 運算器（講義第 3、4 頁）
//   Add = 1                → c = a + b
//   Add = 0，Switch = 1    → c = Sub_Inc_Dec(a, b, ...)   以 a 為主
//   Add = 0，Switch = 0    → c = Sub_Inc_Dec(b, a, ...)   a、b 對調，以 b 為主
//   函數 Sub_Inc_Dec(x, y, Sub, Inc)：
//     Sub = 1          → x - y
//     Sub = 0，Inc = 1 → x + 1
//     Sub = 0，Inc = 0 → x - 1
// =====================================================================
module Func_AS (
    input      [3:0] a,
    input      [3:0] b,
    input            Add,
    input            Sub,
    input            Inc,
    input            Switch,
    output reg [3:0] c
);
    always @(*) begin           // 講義：always @(a or b or Add or Sub or Inc or Switch)
        if (Add)                                 // 相加
            c = a + b;
        else if (Switch)
            c = Sub_Inc_Dec(a, b, Sub, Inc);
        else                                     // Switch = 0：a、b 交換後再呼叫
            c = Sub_Inc_Dec(b, a, Sub, Inc);
        // 呼叫時引數的「順序」要和函數宣告的 input 順序一致；
        // 寫成 Sub_Inc_Dec(a, Sub, b, Inc) 編譯器不一定會報錯，但結果是錯的
    end

    // 函數：回傳值是 4 位元，存在和函數同名的變數 Sub_Inc_Dec 裡
    // Verilog-2001 寫法：輸入直接寫在括號裡
    //   講義（1995）寫法：function [3:0] Sub_Inc_Dec;  input [3:0] a, b;  input Sub, Inc;
    function [3:0] Sub_Inc_Dec (
        input [3:0] a,
        input [3:0] b,
        input       Sub,
        input       Inc
    );
        begin
            if (Sub)                             // 相減
                Sub_Inc_Dec = a - b;
            else if (Inc)                        // 加 1
                Sub_Inc_Dec = a + 1'b1;
            else                                 // 減 1
                Sub_Inc_Dec = a - 1'b1;
        end
    endfunction
endmodule
