`timescale 1ns/1ps

// =====================================================================
// BitWise：判斷輸入的資料是否為奇同位、偶同位、全為 1
//   縮減運算子（Reduction operator）：把一個多位元的值「縮」成 1 個位元
//   ^  縮減 XOR ：1 的個數為奇數 → 1（可當奇同位產生器 odd parity）
//   ~^ 縮減 XNOR：1 的個數為偶數 → 1（偶同位 even parity）
//   &  縮減 AND ：全部都是 1     → 1
// =====================================================================
module BitWise (input_bus, even, odd, all_one);
    input  [7:0] input_bus;
    output       even, odd, all_one;
    wire         even, odd, all_one;

    assign odd     =  ^ input_bus;   // 奇數個 1 則為 1
    assign even    = ~^ input_bus;   // 偶數個 1 則為 1
    assign all_one =  & input_bus;   // 全部為 1 則為 1
endmodule
