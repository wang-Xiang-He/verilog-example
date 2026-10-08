`timescale 1ns/1ps

// =====================================================================
// Func_AS_inc：和 Func_AS 功能完全相同，差別只在函數 Sub_Inc_Dec
//   不寫在這個檔案裡，而是用 `include 從 Sub_Inc_Dec.vh 引入
//   （模組名稱多了 _inc，才能和 Func_AS 同時存在同一個 work 工作庫）
// =====================================================================
module Func_AS_inc (
    input      [3:0] a,
    input      [3:0] b,
    input            Add,
    input            Sub,
    input            Inc,
    input            Switch,
    output reg [3:0] c
);
    always @(*) begin
        if (Add)                                 // 相加
            c = a + b;
        else if (Switch)
            c = Sub_Inc_Dec(a, b, Sub, Inc);
        else                                     // Switch = 0：a、b 交換後再呼叫
            c = Sub_Inc_Dec(b, a, Sub, Inc);
    end

    // `include：編譯前把 Sub_Inc_Dec.vh 的內容「原樣貼」到這個位置
    //   函數必須屬於某個模組，所以這一行一定要寫在 module ... endmodule 之間
    //   注意開頭是反引號 `（鍵盤左上角、數字 1 左邊那個鍵），不是單引號 '
    `include "Sub_Inc_Dec.vh"
endmodule
