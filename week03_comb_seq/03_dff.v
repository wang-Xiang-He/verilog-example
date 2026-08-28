// ============================================================
//  W3-3：D 型正反器 —— 循序邏輯的最小單位
//  重點：同步 reset vs 非同步 reset 的差別（你之前問過的）
// ============================================================
`timescale 1ns / 1ps

module dff (
    input  wire clk,
    input  wire rst,
    input  wire d,
    output reg  q_sync,     // 同步 reset：等時脈邊緣才清
    output reg  q_async,    // 非同步 reset：立刻清
    output reg  q_en        // 有致能的正反器
);

    // ---------- 同步 reset ----------
    //  觸發清單只有 clk → 平常「聽不到」rst
    always @(posedge clk) begin
        if (rst) q_sync <= 1'b0;
        else     q_sync <= d;
    end

    // ---------- 非同步 reset ----------
    //  觸發清單多了 rst → rst 一拉高立刻反應，不等 clk
    always @(posedge clk or posedge rst) begin
        if (rst) q_async <= 1'b0;
        else     q_async <= d;
    end

    // ---------- 有致能：en=0 就保持原值 ----------
    //  注意：這裡「保持原值」是合法的，因為它本來就是循序邏輯，
    //  本來就該有記憶。跟範例 2 的 latch 陷阱不一樣。
    always @(posedge clk) begin
        if (rst)     q_en <= 1'b0;
        else if (d)  q_en <= ~q_en;   // d 當作 toggle 致能
    end

endmodule
