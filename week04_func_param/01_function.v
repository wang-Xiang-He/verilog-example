// ============================================================
//  W4-1：function —— 把重複的組合邏輯包起來
//  重點：function 一定有回傳值、不能有延遲、會被綜合成邏輯閘
// ============================================================
`timescale 1ns / 1ps

module func_demo (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire       parity_a,   // a 的奇同位
    output wire [7:0] max_val,    // a、b 較大者
    output wire [3:0] ones_count  // a 裡面有幾個 1
);

    // ---------- function 的骨架 ----------
    //   function [回傳寬度] 名字 (輸入們);
    //       ... 一定要指定「名字 = 某個值」當回傳
    //   endfunction
    function parity;
        input [7:0] x;
        begin
            parity = ^x;              // 縮減 XOR（第 2 週學的）
        end
    endfunction

    function [7:0] maximum;
        input [7:0] x, y;
        begin
            maximum = (x > y) ? x : y;
        end
    endfunction

    function [3:0] count_ones;
        input [7:0] x;
        integer i;
        begin
            count_ones = 0;
            for (i = 0; i < 8; i = i + 1)
                count_ones = count_ones + x[i];
        end
    endfunction

    // 呼叫方式跟一般函式一樣
    assign parity_a   = parity(a);
    assign max_val    = maximum(a, b);
    assign ones_count = count_ones(a);

endmodule
