`timescale 1ns/1ps

// =====================================================================
// demul1_4_if：1 對 4 解多工器，巢狀 if ... else 寫法（範例練習 5-001）
//   依 {S1, S0} 把輸入 I 送到 y 的第 0~3 位元，其餘位元為 0
//     S1 S0 = 00 → y = {0, 0, 0, I}
//     S1 S0 = 01 → y = {0, 0, I, 0}
//     S1 S0 = 10 → y = {0, I, 0, 0}
//     S1 S0 = 11 → y = {I, 0, 0, 0}
// =====================================================================
module demul1_4_if (
    output reg [3:0] y,         // 埠順序和講義相同：(y, I, S0, S1)
    input            I,
    input            S0,
    input            S1
);
    always @(*) begin           // 講義：always @(I or S0 or S1)
        if (S1 == 1'b0) begin
            if (S0 == 1'b0)
                y = {3'b000, I};           // S = 00
            else
                y = {2'b00, I, 1'b0};      // S = 01
        end
        else begin
            if (S0 == 1'b0)
                y = {1'b0, I, 2'b00};      // S = 10
            else
                y = {I, 3'b000};           // S = 11
        end
    end
endmodule
