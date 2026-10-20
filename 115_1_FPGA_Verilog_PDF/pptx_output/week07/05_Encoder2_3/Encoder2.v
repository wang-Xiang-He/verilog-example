`timescale 1ns/1ps

// =====================================================================
// Encoder2：8 對 3 優先權編碼器，用 assign + 巢狀條件運算子（講義第 18~20 頁）
//   輸入 h 優先權最高、a 最低
//   Out_Vect = {None_ON, Out2, Out1, Out0}：4 位元一起算，再拆成 4 個 1 位元輸出
// =====================================================================
module Encoder2 (
    input        a, b, c, d, e, f, g, h,
    output [3:0] Out_Vect,
    output       None_ON,
    output       Out2,
    output       Out1,
    output       Out0
);
    assign Out_Vect = h ? 4'b0111 :     // 如果 h = 1，則 Out_Vect = 4'b0111     ↑ High
                      g ? 4'b0110 :     // 否則如果 g = 1，則 Out_Vect = 4'b0110  │
                      f ? 4'b0101 :     // 否則如果 f = 1 ...                     │ Priority
                      e ? 4'b0100 :     //                                        │
                      d ? 4'b0011 :     //                                        │
                      c ? 4'b0010 :     //                                        │
                      b ? 4'b0001 :     //                                        │
                      a ? 4'b0000 :     // 否則如果 a = 1，則 Out_Vect = 4'b0000   │ Low
                          4'b1000;      // 否則（全部是 0）：None_ON = 1

    assign None_ON = Out_Vect[3];
    assign Out2    = Out_Vect[2];
    assign Out1    = Out_Vect[1];
    assign Out0    = Out_Vect[0];
    // 講義第 19 頁：「此種設計簡單，但浪費記憶體，可考慮修正為 Pin = 3 bits」
    //   Out_Vect 和 None_ON / Out2 / Out1 / Out0 是同樣的 4 個位元，卻輸出了兩次，多佔 4 支接腳
endmodule
