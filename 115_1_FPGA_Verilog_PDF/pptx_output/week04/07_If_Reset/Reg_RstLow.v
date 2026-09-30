`timescale 1ns/1ps

// =====================================================================
// Reg_RstLow：負準位（Low Active）Reset 的 4 位元暫存器（講義第 23 頁）
//   Clock 正緣時：Reset = 0 → Out 清 0；否則 Out 存入 In_Data
// =====================================================================
module Reg_RstLow (
    input            Clock,
    input            Reset,
    input      [3:0] In_Data,
    output reg [3:0] Out
);
    always @(posedge Clock) begin
        if (!Reset)                // 範例 4 寫法；和範例 3 的 if (Reset == 1'b0) 完全相同
            Out <= 4'b0;
        else
            Out <= In_Data;
    end
endmodule
