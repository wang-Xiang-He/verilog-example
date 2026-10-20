`timescale 1ns/1ps

// =====================================================================
// Accumulator：16 位元累加器，具有「重置」訊號控制（講義第 61~63 頁）
//   累加器的功能在於讓電路中的某個暫存器值能夠一直累加特定的值
//   每個 Clock 正緣：Out = Out + Data_In
//   Reset = 1：立刻清除為 0（非同步重置，不用等 Clock）
// =====================================================================
module Accumulator (
    input             Clock,
    input             Reset,
    input      [15:0] Data_In,
    output reg [15:0] Out
);
    always @(posedge Clock or posedge Reset) begin  // Reset 也放進敏感清單 → 非同步重置
        if (Reset)                  // 重置
            Out <= 16'd0;           // 清除為 0
        else                        // 從輸入埠 Data_In 讀入累加值，輸出埠 Out 加上 Data_In
            Out <= Out + Data_In;
    end
    // 講義第 61 頁方塊圖寫「8 位元累加器」，但程式是 16 位元，這裡以程式為準
endmodule
