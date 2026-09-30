`timescale 1ns/1ps

// =====================================================================
// Add_Reg：z = a + b，用 always 寫 → z 宣告成 reg（講義第 8、14 頁）
// =====================================================================
module Add_Reg (
    input      [3:0] a,
    input      [3:0] b,
    output reg [3:0] z
);
    always @(*) begin          // 講義：always @(a or b)
        z = a + b;
    end
endmodule
