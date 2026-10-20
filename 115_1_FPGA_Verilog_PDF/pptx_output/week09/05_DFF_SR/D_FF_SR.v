`timescale 1ns/1ps

// =====================================================================
// D_FF_SR：具有同步重置（Synchronous Reset）的 D 型正反器（講義第 11、12 頁）
//   Reset 低態動作；但只有在 Clock 正緣時才會檢查 Reset（同步）
// =====================================================================
module D_FF_SR (
    input      Clock,
    input      Reset,
    input      D,
    output reg Q
);
    always @(posedge Clock) begin   // 同步用法：敏感清單只有 Clock
        if (!Reset)                 // Reset = 0
            Q <= 1'b0;              // 清除為 0
        else
            Q <= D;                 // 將 D 傳入 Q
    end
endmodule
