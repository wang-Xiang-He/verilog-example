`timescale 1ns/1ps

// =====================================================================
// Reg_16：具有「清除」訊號的 16 位元暫存器（講義第 13、14 頁）
//   Clear = 0 → Reg_Out = 0（清為 0）
//   Clear = 1 → Reg_Out = Reg_In（載入資料）
//   [16:1]：位元編號從 1 到 16，共 16 - 1 + 1 = 16 位元（不一定要從 0 開始）
// =====================================================================
module Reg_16 (
    input             Clear,
    input      [16:1] Reg_In,
    output reg [16:1] Reg_Out
);
    always @(*) begin               // 講義：always @(Clear or Reg_In)（event list）
        case (Clear)
            1'b0: Reg_Out[16:1] = 16'b0;            // 清為 0
            1'b1: Reg_Out[16:1] = Reg_In[16:1];     // 載入資料
        endcase
    end
    // ※ 這個電路沒有時脈：Clear = 0 / 1 時，Reg_Out 都直接由輸入決定，其實是「組合邏輯」
    //   只有 Clear 是 x / z（兩個 case 都比不到）時，Reg_Out 才會「保持」舊值 → 那時才像 latch
endmodule
