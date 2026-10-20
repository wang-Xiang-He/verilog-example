`timescale 1ns/1ps

// =====================================================================
// Enable_FF1：具有「致能」輸出控制訊號的正反器（講義第 7、8 頁）
//   Clock 正緣時：
//     Enable = 1：Condition = 0 → Q = D；Condition = 1 → Q = Q（保持）
//     Enable = 0：Q = x（設定為不確定值，Unknown Value）
//   方塊圖上 Condition 腳有小圓圈 = 低態動作（0 時才讓 D 進來）
// =====================================================================
module Enable_FF1 (
    input      Clock,
    input      Condition,
    input      Enable,
    input      D,
    output reg Q
);
    always @(posedge Clock) begin
        if (Enable)                         // 「致能」輸出
            Q <= (~Condition) ? D : Q;      // 若 Condition = 0，則 Q = D
        else
            Q <= 1'bx;                      // 設定為 x（不確定值，Unknown Value）
    end
endmodule
