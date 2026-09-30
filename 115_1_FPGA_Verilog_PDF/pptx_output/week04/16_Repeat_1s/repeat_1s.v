`timescale 1ns/1ps

// =====================================================================
// repeat_1s：計算 8 位元資料中有幾個 1（範例練習 5-004，講義第 47~49 頁）
//   repeat 迴圈執行 8 次，每次檢查 tmpr 的最低位元 tmpr[0]，
//   是 1 就把計數器加 1，然後 tmpr 右移一位
// =====================================================================
module repeat_1s #(
    parameter length = 8
) (
    output reg [3:0]        ones,    // 埠順序和講義相同：(ones, Din)
    input      [length-1:0] Din
);
    reg [length-1:0] tmpr;
    reg [3:0]        Cout;

    always @(*) begin                // 講義：always @(Din)
        Cout = 4'b0;
        tmpr = Din;
        repeat (length) begin
            if (tmpr[0])
                Cout = Cout + 4'b0001;
            tmpr = tmpr >> 1;
        end
        ones = Cout;
    end
endmodule
