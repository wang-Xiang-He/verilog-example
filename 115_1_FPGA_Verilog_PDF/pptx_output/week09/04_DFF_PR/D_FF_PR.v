`timescale 1ns/1ps

// =====================================================================
// D_FF_PR：具有非同步（Asynchronous）重置（Reset）與預設（Preset）的 D 型正反器（講義第 9、10 頁）
//   Reset、Preset 都是低態動作（方塊圖上有小圓圈）
//   Reset = 0  → 立刻 Q = 0（不等 Clock）
//   Preset = 0 → 立刻 Q = 1（不等 Clock）
//   兩個都是 1 → Clock 正緣時 Q = D
// =====================================================================
module D_FF_PR (
    input      Clock,
    input      Reset,
    input      Preset,
    input      D,
    output reg Q
);
    // 非同步用法：Reset、Preset 也放進敏感清單（低態動作 → negedge）
    always @(negedge Reset or negedge Preset or posedge Clock) begin
        if (!Reset)                 // Reset = 0
            Q <= 1'b0;              // 清除為 0
        else if (!Preset)           // Preset = 0
            Q <= 1'b1;              // 設定為 1
        else                        // 講義寫 else if (Clock)；能進到這裡一定是 Clock 正緣，if (Clock) 可以省略
            Q <= D;                 // 將 D 傳入 Q
    end
endmodule
