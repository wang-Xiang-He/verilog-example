`timescale 1ns/1ps

// =====================================================================
// And3_Posedge：Case II 正緣觸發（講義第 20 頁 範例 1）
//   只在 Clock 由 0 → 1 時計算 → 合成為 AND 閘 + 正緣正反器
// =====================================================================
module And3_Posedge (
    input      Clock,
    input      a,
    input      b,
    input      c,
    output reg f
);
    always @(posedge Clock)
        f <= a & b & c;    // 講義寫 f = a & b & c；正反器建議用非阻隔式 <=
endmodule
