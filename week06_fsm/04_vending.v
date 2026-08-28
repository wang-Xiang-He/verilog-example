// ============================================================
//  W6-4：投幣式販賣機 —— 狀態機綜合應用
//  規格：飲料 25 元，可投 5 元和 10 元，會找零
// ============================================================
`timescale 1ns / 1ps

module vending (
    input  wire       clk,
    input  wire       rst,
    input  wire       coin5,        // 投 5 元（單拍脈衝）
    input  wire       coin10,       // 投 10 元
    output reg        dispense,     // 出貨
    output reg  [1:0] change,       // 找零幾個 5 元
    output wire [2:0] total_out     // 目前累積金額 / 5
);

    // 用「已投入金額 / 5」當狀態：0,1,2,3,4 → 0元,5元,10元,15元,20元
    reg [2:0] total, next_total;
    reg [1:0] next_change;
    reg       next_dispense;

    assign total_out = total;

    // ===== 第 1 段：狀態暫存器 =====
    always @(posedge clk) begin
        if (rst) begin
            total    <= 3'd0;
            dispense <= 1'b0;
            change   <= 2'd0;
        end else begin
            total    <= next_total;
            dispense <= next_dispense;
            change   <= next_change;
        end
    end

    // ===== 第 2+3 段：下一狀態 + 輸出（狀態少時常合併寫）=====
    always @(*) begin
        next_total    = total;          // 預設：不動（避免 latch）
        next_dispense = 1'b0;
        next_change   = 2'd0;

        if (coin5) begin
            if (total + 3'd1 >= 3'd5) begin        // 湊到 25 元
                next_dispense = 1'b1;
                next_change   = (total + 3'd1) - 3'd5;
                next_total    = 3'd0;
            end else begin
                next_total = total + 3'd1;
            end
        end else if (coin10) begin
            if (total + 3'd2 >= 3'd5) begin
                next_dispense = 1'b1;
                next_change   = (total + 3'd2) - 3'd5;
                next_total    = 3'd0;
            end else begin
                next_total = total + 3'd2;
            end
        end
    end

endmodule
