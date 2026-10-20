`timescale 1ns/1ps

// =====================================================================
// Latch_RS：具有「重置」、「設定」以及「輸出致能」訊號控制的準位感測閂鎖（D-type Latch）（講義第 1、2 頁）
//   Reset = 1                        → Q = 0
//   Reset = 0，Set = 1               → Q = 1
//   Reset = 0，Set = 0，Enable = 1   → Q = D（透明：D 怎麼變 Q 就怎麼變）
//   Reset = 0，Set = 0，Enable = 0   → Q = Q（保持，這就是「記憶」）
//   Priority：Reset > Set > Enable
// =====================================================================
module Latch_RS (
    input  Enable,
    input  Set,
    input  Reset,
    input  D,
    output Q
);
    // 最內層的「: Q」把輸出接回自己 → 組合邏輯形成迴授（feedback）→ 能記住值 = 閂鎖
    assign Q = Reset ? 1'b0 : (Set ? 1'b1 : (Enable ? D : Q));
endmodule
