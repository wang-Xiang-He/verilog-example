// ============================================================
//  期中考 第 2 題：可預載的上下數計數器
//  難度：★★☆   考的是：第 3、4 週（循序邏輯、優先順序、參數）
// ============================================================
`timescale 1ns / 1ps

//  要求（優先順序由高到低）：
//    1. rst  = 1        → count 歸 0
//    2. load = 1        → count 載入 din
//    3. en   = 1 且 up=1 → count + 1（到頂 2^W-1 之後繞回 0）
//    4. en   = 1 且 up=0 → count - 1（到 0 之後繞回 2^W-1）
//    5. en   = 0        → 保持不變
//
//  另外：
//    at_max 在 count 等於最大值時為 1
//    at_min 在 count 等於 0     時為 1
//
//  ★ 全部用同步邏輯（只看 posedge clk）

module updown #(
    parameter W = 4
)(
    input  wire         clk,
    input  wire         rst,
    input  wire         load,
    input  wire         en,
    input  wire         up,
    input  wire [W-1:0] din,
    output reg  [W-1:0] count,
    output wire         at_max,
    output wire         at_min
);

    // ★★★ 在這裡寫你的答案 ★★★

    always @(posedge clk) begin
        // 提示：用 if / else if 串起來，順序就是優先順序
        count <= count;      // ← 把這行換掉
    end

    assign at_max = 1'b0;    // ← 換掉
    assign at_min = 1'b0;    // ← 換掉

endmodule
