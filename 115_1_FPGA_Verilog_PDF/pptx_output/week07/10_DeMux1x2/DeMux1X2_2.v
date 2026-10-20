`timescale 1ns/1ps

// =====================================================================
// DeMux1X2_2：1 對 2 解多工器，範例 2：使用 if ... else 敘述（講義第 47、48 頁）
// =====================================================================
module DeMux1X2_2 (
    input      D,
    input      Select,
    output reg Y0,
    output reg Y1
);
    always @(*) begin           // 講義：always @(D or Select)
        if (Select == 1'b0) begin
            Y0 = D;
            Y1 = 0;
        end
        else if (Select == 1'b1) begin
            Y0 = 0;
            Y1 = D;
        end
        // 講義沒有最後的 else：Select 是 x 或 z 時兩個 if 都不成立，Y0、Y1 保持原來的值
        //   「保持」= 需要記憶 → 合成時會產生 latch（閂鎖器）。測試平台會示範這個現象
    end
endmodule
