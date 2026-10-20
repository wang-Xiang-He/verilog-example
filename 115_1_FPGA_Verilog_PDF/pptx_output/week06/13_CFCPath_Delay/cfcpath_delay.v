`timescale 1ns/1ps

// =====================================================================
// cfcpath_delay：條件式完全連接路徑時間延遲的設定（State-Dependent Path Delay，範例練習 7-009，講義第 39~42 頁）
//   電路：y = (a1 & a2) | (a3 & a4)
//     a1 ─┐
//         AND1 ── y1 ─┐
//     a2 ─┘           │
//                     OR1 ── y
//     a3 ─┐           │
//         AND2 ── y2 ─┘
//     a4 ─┘
// =====================================================================
module cfcpath_delay (
    input  a1,
    input  a2,
    input  a3,
    input  a4,
    output y
);
    wire y1, y2;

    // if (條件) (來源 *> 目的) = 延遲;   狀態相關路徑延遲（條件式延遲）
    //   條件成立時，才使用這個延遲；條件都不成立時，這條路徑沒有延遲（0）
    //   條件裡只能用輸入埠，而且 if 後面【不能】接 else
    specify
        if ({a1, a2} == 2'b11) (a1, a2 *> y) = 10;   // 若 (a1 a2) = (11)，路徑 a1、a2 → y 延遲 10
        if ({a3, a4} == 2'b11) (a3, a4 *> y) = 12;   // 若 (a3 a4) = (11)，路徑 a3、a4 → y 延遲 12
    endspecify

    and and1 (y1, a1, a2);
    and and2 (y2, a3, a4);
    or  or1  (y,  y1, y2);
endmodule
