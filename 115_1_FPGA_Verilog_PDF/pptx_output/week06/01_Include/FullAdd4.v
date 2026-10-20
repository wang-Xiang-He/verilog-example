`timescale 1ns/1ps

// =====================================================================
// FullAdd4：4 位元漣波進位加法器（Ripple Carry Adder）（講義第 2、3 頁）
//   用 `include 引用已經設計好的 1 位元全加器 FullAdd.v，一起編譯
//   ※ vlog 只要編譯 FullAdd4.v 和 FullAdd4_tb.v，FullAdd.v 會被 `include 自動帶進來
// =====================================================================

// `include：編譯前把 FullAdd.v 的內容「原樣貼」到這一行的位置
//   開頭是反引號 `（鍵盤左上角、數字 1 左邊那個鍵），不是單引號 '
//   路徑寫法（講義第 2 頁）：
//     "FullAdd.v"              同一個資料夾（最常用）
//     "D:/test/FullAdd.v"      斜線 /，Windows 也可以用
//     "D:\\test\\FullAdd.v"    反斜線要寫兩個
//     "D:\test\FullAdd.v"        錯：字串裡的 \ 是跳脫字元（\t 會變成 Tab）
`include "FullAdd.v"        // 引用 FullAdd.v 檔中的所有可用模組

module FullAdd4 (
    input  [3:0] a,
    input  [3:0] b,
    input        Carry_In,
    output [3:0] Sum,
    output       Carry_Out
);
    // 講義第 3 頁：Carry_Out1、Carry_Out2、Carry_Out3「可不宣告」
    //   沒宣告的名字接在埠上，Verilog 會自動當成 1 位元 wire（隱含宣告 implicit net）
    //   這裡還是宣告出來：多位元訊號如果靠隱含宣告，只會剩 1 位元，很難除錯
    wire Carry_Out1, Carry_Out2, Carry_Out3;

    // 依順序連接：FullAdd 的埠順序是 (a, b, CarryIn, Sum, CarryOut)
    FullAdd fa0 (a[0], b[0], Carry_In,   Sum[0], Carry_Out1);
    FullAdd fa1 (a[1], b[1], Carry_Out1, Sum[1], Carry_Out2);
    FullAdd fa2 (a[2], b[2], Carry_Out2, Sum[2], Carry_Out3);
    FullAdd fa3 (a[3], b[3], Carry_Out3, Sum[3], Carry_Out);
endmodule
