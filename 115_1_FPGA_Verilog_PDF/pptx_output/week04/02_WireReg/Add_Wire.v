`timescale 1ns/1ps

// =====================================================================
// Add_Wire：和 Add_Reg 功能完全相同，改用 assign 寫 → z 是 wire（講義第 8 頁）
// =====================================================================
module Add_Wire (
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] z             // 沒寫型態 → 預設為 wire
);
    assign z = a + b;
endmodule
