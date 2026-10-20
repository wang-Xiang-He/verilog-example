`timescale 1ns/1ps

// =====================================================================
// Mux4to1_1：4 對 1 多工器，用 case（講義第 37~39 頁）
//   {S1, S0} = 00 → A、01 → B、10 → C、11 → D
// =====================================================================
module Mux4to1_1 (
    input      A, B, C, D,
    input      S1, S0,
    output reg Out
);
    always @(*) begin           // 講義：always @(A or B or C or D or S1 or S0)
        case ({S1, S0})
            2'b00: Out = A;
            2'b01: Out = B;
            2'b10: Out = C;
            2'b11: Out = D;
            default: Out = 1'bx;    // 講義沒有；S1、S0 有 x 時補上，避免 Out 保持舊值
        endcase
    end
endmodule
