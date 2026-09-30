`timescale 1ns/1ps

// =====================================================================
// Mux_Case：用 case 寫 4 選 1 多工器（講義第 32 頁 範例 3）
//   各項目互斥（同一時間只會有一個成立）→ 合成為平行的多工器，沒有優先權
// =====================================================================
module Mux_Case (
    input      [1:0] select,
    input      [3:0] in1,
    input      [3:0] in2,
    input      [3:0] in3,
    input      [3:0] in4,
    output reg [3:0] Out
);
    always @(*) begin           // 講義：always @(select)，漏了 in1~in4，見說明
        case (select)           // synopsys parallel_case
            2'b00   : Out = in1;
            2'b01   : Out = in2;
            2'b10   : Out = in3;      // 講義只列 00、01、11，沒有 10 → 會合成出 Latch，這裡補上
            2'b11   : Out = in4;
            default : Out = 4'bx;     // select 含 x / z 時
        endcase
    end
endmodule
