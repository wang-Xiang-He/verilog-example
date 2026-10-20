`timescale 1ns/1ps

// =====================================================================
// Mux2to1_1：2 對 1 多工器，第 1 種寫法：if ... else（講義第 29、30 頁）
//   Select = 1 → Out = a；否則 Out = b
// =====================================================================
module Mux2to1_1 (
    input  a,
    input  b,
    input  Select,
    output reg Out              // always 的 begin ... end 內，被賦值的輸出變數僅可為 reg 型態
);
    always @(*) begin           // 講義：always @(a or b or Select)，a 或 b 或 Select 變動就執行
        if (Select)
            Out = a;
        else
            Out = b;
    end
    // 講義第 29 頁問「程式有誤？」：第 28 頁的真值表是 Select = 0 → a、1 → b，
    //   但程式寫的是 Select = 1 → a。程式本身沒有語法錯誤，只是和真值表相反。
    //   第 31、33、35 頁的寫法也都是 Select = 1 → a，本資料夾 4 個模組都照程式的定義
endmodule
