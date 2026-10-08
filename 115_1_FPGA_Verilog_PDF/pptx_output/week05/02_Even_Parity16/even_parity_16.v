`timescale 1ns/1ps

// =====================================================================
// even_parity_16：16 位元偶同位元產生器（範例練習 6-001，講義第 6~8 頁）
//   把 16 位元拆成高、低兩個位元組，各呼叫一次 8 位元的函數 even8，
//   兩個結果再 XOR 得到 16 位元的偶同位元 Pout
//   偶同位：Din 加上 Pout 之後，1 的總個數是偶數
// =====================================================================
module even_parity_16 (
    input      [15:0] Din,      // 埠順序和講義相同：(Din, Pout)
    output reg        Pout
);
    reg [7:0] High_byte;
    reg [7:0] Low_byte;
    reg       High, Low;

    always @(*) begin           // 講義：always @(Din)
        High_byte = Din[15:8];
        Low_byte  = Din[7:0];
        High = even8(High_byte);
        Low  = even8(Low_byte);
        Pout = High ^ Low;
    end

    // 沒寫位元寬度 → 回傳值是 1 位元
    function even8 (input [7:0] I);
        begin
            even8 = ^I;         // 縮減 XOR：8 個位元全部 XOR 起來
        end
    endfunction
endmodule
