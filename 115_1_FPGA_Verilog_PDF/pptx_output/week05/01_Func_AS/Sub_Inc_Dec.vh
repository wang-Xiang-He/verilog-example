// =====================================================================
// Sub_Inc_Dec.vh：把函數獨立成一個檔案，給 `include 使用
//   Sub = 1          → a - b
//   Sub = 0，Inc = 1 → a + 1
//   Sub = 0，Inc = 0 → a - 1
//
// 使用方式：在要用它的模組「裡面」（module 和 endmodule 之間）寫
//     `include "Sub_Inc_Dec.vh"
//
// 注意：
//   1. 這個檔案只有 function，沒有 module，所以【不能單獨編譯】
//      vlog 的檔案清單不要列它，否則會出現
//      (vlog-2155) Global declarations are illegal in Verilog 2001 syntax.
//   2. 副檔名用 .vh（Verilog header）就是提醒：這是給別人 include 的片段
//   3. 這裡不寫 `timescale，沿用引入它的那個檔案的設定
// =====================================================================
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
