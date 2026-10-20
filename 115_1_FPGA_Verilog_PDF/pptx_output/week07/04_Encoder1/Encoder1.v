`timescale 1ns/1ps

// =====================================================================
// Encoder1：8 對 3 優先權編碼器（Priority Encoder），用 for 迴圈（講義第 15~17 頁）
//   In[7] 優先權最高、In[0] 最低；Out = 「是 1 的最高位元」的位置
//   In = 0000_0000 時沒有任何輸入啟動 → None_ON = 1
//     In[7] In[6] ... In[0]  | Out[2:0] None_ON
//       1     X   ...   X    |   111      0
//       0     1   ...   X    |   110      0
//       ...
//       0     0   ...   1    |   000      0
//       0     0   ...   0    |   000      1
// =====================================================================
module Encoder1 (
    input      [7:0] In,
    output reg [2:0] Out,
    output reg       None_ON
);
    always @(*) begin : Encoder_Block       // 講義：always @(In)
        // begin 後面加「: 名稱」= 具名區塊（named block）
        //   區塊裡才可以宣告區域變數（local variable），例如這裡的 integer i
        integer i;

        Out     = 0;                        // 設定初始值（initial value）
        None_ON = 1;
        for (i = 0; i < 8; i = i + 1)       // 從 In[0] 往 In[7] 掃
            if (In[i]) begin                // 傳回 Highest Bit 為 1 的位置
                Out     = i;                // 後面（較高位）的 1 會蓋掉前面的
                None_ON = 0;
            end
    end
    // 講義第 16 頁：「此種設計不好：當 In = 11H = 0001_0001 時，out = 0 or out = 4（Maybe error?）」
    //   模擬結果是 4（正確）：迴圈先遇到 In[0] 設成 0，再遇到 In[4] 蓋成 4
    //   這種寫法要靠「後面蓋掉前面」才對，讀程式的人不容易一眼看出優先權
endmodule
