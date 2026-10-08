`timescale 1ns/1ps

// =====================================================================
// even16_fun_fun：函數呼叫函數（範例練習 6-004，講義第 24~27 頁）
//   16 位元偶同位元產生器，由 02_Even_Parity16 修改而來：
//     主模組 → 呼叫 even8（8 位元）→ even8 再呼叫 even4（4 位元）
// =====================================================================
module even16_fun_fun (
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

    // 8 位元偶同位：拆成兩個 4 位元，各呼叫一次 even4，結果再 XOR
    function even8 (input [7:0] I8);
        begin
            even8 = even4(I8[7:4]) ^ even4(I8[3:0]);
        end
    endfunction

    // 4 位元偶同位（最底層）
    function even4 (input [3:0] I4);
        begin
            even4 = ^I4;
        end
    endfunction
endmodule
