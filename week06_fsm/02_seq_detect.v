// ============================================================
//  W6-2：序列偵測器 —— 抓出資料流裡的「1011」
//  重點：Moore vs Mealy 的差別，兩種寫在同一個模組裡對照
// ============================================================
`timescale 1ns / 1ps

module seq_detect (
    input  wire clk,
    input  wire rst,
    input  wire din,
    output reg  found_moore,     // Moore：慢一拍，但輸出乾淨
    output wire found_mealy,     // Mealy：即時，但可能有毛刺
    output wire [2:0] state_out
);

    localparam S0    = 3'd0;   // 還沒看到東西
    localparam S1    = 3'd1;   // 看到 1
    localparam S10   = 3'd2;   // 看到 10
    localparam S101  = 3'd3;   // 看到 101
    localparam S1011 = 3'd4;   // 看到 1011  ← 目標！

    reg [2:0] state, next_state;
    assign state_out = state;

    // 第 1 段
    always @(posedge clk) begin
        if (rst) state <= S0;
        else     state <= next_state;
    end

    // 第 2 段
    always @(*) begin
        next_state = S0;
        case (state)
            S0:    next_state = din ? S1    : S0;
            S1:    next_state = din ? S1    : S10;
            S10:   next_state = din ? S101  : S0;
            S101:  next_state = din ? S1011 : S10;
            S1011: next_state = din ? S1    : S10;   // 允許重疊偵測
            default: next_state = S0;
        endcase
    end

    // 第 3 段（Moore）：只看狀態 → 進到 S1011 的「下一拍」才拉高
    always @(*) begin
        found_moore = (state == S1011);
    end

    // Mealy：看狀態 + 輸入 → 當下就拉高，比 Moore 早一拍
    assign found_mealy = (state == S101) && din;

endmodule
