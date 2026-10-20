`timescale 1ns/1ps

// =====================================================================
// DeMux1X4_2：1 對 4 解多工器，範例 2：使用 if ... else 敘述（講義第 51 頁）
//   ※ 講義的檔名是 DeM1X4_2.V，但模組名稱寫成 DeMux1x4_1，和範例 1 同名
//     兩個一起編譯時，後編譯的會蓋掉先編譯的，所以改名為 DeMux1X4_2
// =====================================================================
module DeMux1X4_2 (
    input      D,
    input      S1, S0,
    output reg Y0, Y1, Y2, Y3
);
    always @(*) begin           // 講義：always @(D or S0 or S1)
        if ((S1 == 1'b0) & (S0 == 1'b0)) begin              // & = 且（兩個比較的結果都是 1 位元）
            Y0 = D;  Y1 = 0;  Y2 = 0;  Y3 = 0;
        end
        else if ((S1 == 1'b0) & (S0 == 1'b1)) begin
            Y0 = 0;  Y1 = D;  Y2 = 0;  Y3 = 0;
        end
        else if ((S1 == 1'b1) & (S0 == 1'b0)) begin
            Y0 = 0;  Y1 = 0;  Y2 = D;  Y3 = 0;
        end
        else if ((S1 == 1'b1) & (S0 == 1'b1)) begin
            Y0 = 0;  Y1 = 0;  Y2 = 0;  Y3 = D;
        end
        // 和 10_DeMux1x2 一樣，講義沒有最後的 else → S1 / S0 不確定時輸出保持舊值（latch）
    end
endmodule
