// ============================================================
//  W3-1：用 always @(*) 寫組合邏輯
//  重點：always 不是只能配時脈；@(*) 是組合邏輯的標準寫法
// ============================================================
`timescale 1ns / 1ps

module case_mux (
    input  wire [3:0] d0, d1, d2, d3,
    input  wire [1:0] sel,
    output reg  [3:0] y,          // ★ 在 always 裡被賦值 → 必須宣告成 reg
    output reg  [7:0] decoded     // 3-to-8 解碼器
);

    //  @(*) 的意思是「只要右邊任何一個輸入變了，就重算」
    //  這才是組合邏輯：沒有記憶，隨時反應
    always @(*) begin
        case (sel)
            2'd0: y = d0;
            2'd1: y = d1;
            2'd2: y = d2;
            2'd3: y = d3;
            default: y = 4'bxxxx;   // ★ 一定要有 default
        endcase
    end

    // 解碼器：把 2 位元的 sel 變成「只有一位是 1」的 4 位元
    always @(*) begin
        decoded = 8'b0000_0000;     // ★ 先給預設值，避免產生 latch
        decoded[sel] = 1'b1;
    end

endmodule
