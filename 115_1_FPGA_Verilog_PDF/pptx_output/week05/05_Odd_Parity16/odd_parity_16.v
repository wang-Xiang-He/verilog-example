`timescale 1ns/1ps

// =====================================================================
// odd_parity_16：16 位元奇同位元產生器（範例練習 6-003，講義第 18~22 頁）
//   和 02_Even_Parity16 結構相同，但改用「任務」odd8，而且是奇同位
//   奇同位：Din 加上 Pout 之後，1 的總個數是奇數
// =====================================================================
module odd_parity_16 (
    input      [15:0] Din,      // 埠順序和講義相同：(Din, Pout)
    output reg        Pout
);
    reg [7:0] High_byte;
    reg [7:0] Low_byte;
    reg       High, Low;

    always @(*) begin           // 講義：always @(Din)
        High_byte = Din[15:8];
        Low_byte  = Din[7:0];
        odd8(High_byte, High);  // 任務沒有回傳值：結果從 output 引數（High）拿回來
        odd8(Low_byte,  Low);
        Pout = High ~^ Low;     // XNOR
    end

    // 任務：8 位元奇同位元
    //   講義把輸出也取名叫 odd8（和任務同名），這裡改叫 P 避免混淆
    task odd8 (
        input  [7:0] I,
        output       P
    );
        begin
            P = ~^I;            // 縮減 XNOR：8 個位元 XOR 後再反相
        end
    endtask
endmodule
