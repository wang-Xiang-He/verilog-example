`timescale 1ns/1ps

// =====================================================================
// And3_Negedge：Case II 負緣觸發（講義第 20 頁 範例 2）
//   只在 Clock 由 1 → 0 時計算 → 合成為 AND 閘 + 負緣正反器
// =====================================================================
module And3_Negedge (
    input      Clock,
    input      a,
    input      b,
    input      c,
    output reg f
);
    always @(negedge Clock)
        f <= a & b & c;
endmodule
