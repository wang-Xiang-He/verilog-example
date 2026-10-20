`timescale 1ns/1ps

// =====================================================================
// Mux4x1_By_Mux2to1E：使用二個 2X1 的多工器擴充成一個 4X1 的多工器（講義第 40~43 頁）
//   S1 = 0：經過反向器 Not_S1 = 1 → 上面那顆 Mux 動作，由 S0 選 I0 或 I1；下面那顆不動作（輸出 0）
//   S1 = 1：下面那顆 Mux 動作，由 S0 選 I2 或 I3；上面那顆不動作（輸出 0）
//   兩顆的輸出再做 OR → 不動作的那顆是 0，OR 的結果就是動作的那顆
//   ※ vlog 只要編譯本檔和 testbench，Mux2to1E.v 會被 `include 自動帶進來
// =====================================================================
`include "Mux2to1E.v"           // 編譯命令引用 Mux2to1E.v（講義寫 "Mux2to1E.V"，檔名大小寫要和實際檔案一樣）

module Mux4x1_By_Mux2to1E (
    input      S1, S0,
    input      I3, I2, I1, I0,
    output reg Out
);
    wire Out0, Out1;
    wire Not_S1;                // 內部的接線

    assign Not_S1 = !S1;

    // 引用 2 個具有輸出致能（Enable，由 S1 控制）訊號的 2X1 多工器
    //   Port Mapping - in order：Mux2to1E (Enable, Select, I0, I1, Y)
    Mux2to1E My1_Mux2to1 (Not_S1, S0, I0, I1, Out0);
    Mux2to1E My2_Mux2to1 (S1,     S0, I2, I3, Out1);

    always @(*) begin           // 講義：always @(Out0 or Out1)
        Out = Out0 | Out1;      // 將 2X1 多工器的輸出訊號作 OR 的連接
    end
endmodule
