`timescale 1ns/1ps

// =====================================================================
// Comparator：8 位元比較器，結果在時脈 CLK 正緣更新（講義第 58~60 頁，檔名 Cmp8bit.V）
//   A > B → AGTB = 1（A Greater Than B）
//   A = B → AEQB = 1（A Equal to B）
//   A < B → ALTB = 1（A Less Than B）
//   三種情況只有一個為真（True），其餘為偽（False）
// =====================================================================
module Comparator #(
    parameter size = 8              // 易於修改
) (
    input  [size-1:0] A,
    input  [size-1:0] B,
    input             CLK,
    output reg        AGTB,
    output reg        AEQB,
    output reg        ALTB
);
    always @(posedge CLK) begin     // Behavioral Model
        AGTB <= (A >  B);           // 講義用阻隔式 =；時脈觸發改用非阻隔式 <=
        AEQB <= (A == B);
        ALTB <= (A <  B);
    end
endmodule
