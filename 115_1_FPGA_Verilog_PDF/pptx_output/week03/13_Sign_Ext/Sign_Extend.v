`timescale 1ns/1ps

// =====================================================================
// Sign_Extend：8 位元擴展成 16 位元
//   SignExtend = 1：高 8 位元補 Word[7]（符號位元擴展，有號數數值不變）
//   SignExtend = 0：高 8 位元補 0（無號數擴展）
// =====================================================================
module Sign_Extend (
    input             SignExtend,
    input      [7:0]  Word,
    output reg [15:0] Double        // 在 always 裡被賦值 → reg
);
    // @(*)：自動把區塊內讀到的訊號都放進敏感清單（組合邏輯）
    //   講義寫 @(SignExtend or Word)，功能相同，但手寫容易漏列
    always @(*) begin
        if (SignExtend)
            Double = {{8{Word[7]}}, Word};   // 重複運算子：8{Word[7]} = Word[7] 重複 8 次
        else
            Double = {8'b0, Word};           // 補 8 個 0
    end
    // 組合邏輯的 always 用阻隔式 = 是正確的（和正反器用 <= 不同）
endmodule
