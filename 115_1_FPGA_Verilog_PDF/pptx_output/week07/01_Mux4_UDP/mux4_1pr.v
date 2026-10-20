`timescale 1ns/1ps

// =====================================================================
// mux4_1pr：用 3 顆自定的 mux2_1pr 組成 4 對 1 多工器（範例練習 8-001，講義第 1、4、5 頁）
//   Sel = 00 → DI[0]、01 → DI[1]、10 → DI[2]、11 → DI[3]
//
//          DI[0] ─┐                     （講義第 6 頁的選擇樹）
//   mux2_1pr2     ├─ Y0 ─┐                       DI[3:0]
//          DI[1] ─┘      │                   Sel[1]=1 ／ ＼ Sel[1]=0
//              Sel[0]    ├─ mux2_1pr0 ─ OUT    DI[3:2]     DI[1:0]
//          DI[2] ─┐      │   Sel[1]          Sel[0]: 1/ \0   1/ \0
//   mux2_1pr1     ├─ Y1 ─┘                     DI[3] DI[2] DI[1] DI[0]
//          DI[3] ─┘
//              Sel[0]
//   ※ 需要 mux2_1pr.v 一起編譯
// =====================================================================
module mux4_1pr (
    output       OUT,
    input  [3:0] DI,
    input  [1:0] Sel
);
    wire Y1, Y0;

    // UDP 的實例【只能依順序】連接（講義第 5 頁：Primitive 使用必須 call by order，call by name 不可以）
    //   順序和 mux2_1pr 的宣告 (Y, I1, I0, S) 一樣
    //   講義第 4 頁寫成 mux2_1pr mux2_1pr1(.Y(Y1), .I1(DI[3]), ...) 的依名稱寫法：
    //     vlog 編譯會過，但 vsim 載入時出現 ** Fatal: (vsim-3367) UDP ports cannot be connected by name.
    mux2_1pr mux2_1pr1 (Y1,  DI[3], DI[2], Sel[0]);
    mux2_1pr mux2_1pr2 (Y0,  DI[1], DI[0], Sel[0]);
    mux2_1pr mux2_1pr0 (OUT, Y1,    Y0,    Sel[1]);
endmodule
