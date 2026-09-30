`timescale 1ns/1ps

// =====================================================================
// bin2gra：8 位元二進制碼轉格雷碼（範例練習 5-003，講義第 43~45 頁）
//   Gry[i] = Bin[i] ^ Bin[i+1]    （i = 0 ~ length-2）
//   Gry[最高位] = Bin[最高位]
// =====================================================================
module bin2gra #(
    parameter length = 8
) (
    output reg [length-1:0] Gry,     // 埠順序和講義相同：(Gry, Bin)
    input      [length-1:0] Bin
);
    integer i;

    always @(*) begin                // 講義：always @(Bin)
        for (i = 0; i < length - 1; i = i + 1)
            Gry[i] = Bin[i] ^ Bin[i+1];
        Gry[i] = Bin[i];             // 迴圈結束時 i = length-1，也就是最高位
    end
    // 同樣的功能也可以一行寫完：assign Gry = Bin ^ (Bin >> 1);
endmodule
