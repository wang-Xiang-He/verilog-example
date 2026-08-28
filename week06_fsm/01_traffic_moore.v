// ============================================================
//  W6-1：Moore 型狀態機 —— 紅綠燈
//  重點：★ 三段式寫法 ★（業界標準，一輩子都這樣寫）
// ============================================================
`timescale 1ns / 1ps

module traffic (
    input  wire       clk,
    input  wire       rst,
    output reg  [2:0] light,      // {紅, 黃, 綠}
    output wire [1:0] state_out   // 拉出來給波形看
);

    // ---------- 狀態編碼 ----------
    localparam S_RED    = 2'd0;
    localparam S_GREEN  = 2'd1;
    localparam S_YELLOW = 2'd2;

    // 每個狀態停幾拍
    localparam T_RED    = 5;
    localparam T_GREEN  = 4;
    localparam T_YELLOW = 2;

    reg [1:0] state, next_state;
    reg [3:0] timer;

    assign state_out = state;

    // ===== 第 1 段：狀態暫存器（時序邏輯，用 <=）=====
    always @(posedge clk) begin
        if (rst) begin
            state <= S_RED;
            timer <= 0;
        end else if (state != next_state) begin
            state <= next_state;
            timer <= 0;                    // 換狀態時計時歸零
        end else begin
            timer <= timer + 1'b1;
        end
    end

    // ===== 第 2 段：下一狀態邏輯（組合邏輯，用 =）=====
    always @(*) begin
        next_state = state;                // ★ 預設值：留在原狀態（避免 latch）
        case (state)
            S_RED:    if (timer >= T_RED    - 1) next_state = S_GREEN;
            S_GREEN:  if (timer >= T_GREEN  - 1) next_state = S_YELLOW;
            S_YELLOW: if (timer >= T_YELLOW - 1) next_state = S_RED;
            default:                             next_state = S_RED;
        endcase
    end

    // ===== 第 3 段：輸出邏輯（組合邏輯，用 =）=====
    //  Moore：輸出只看「現在的狀態」，不看輸入
    always @(*) begin
        case (state)
            S_RED:    light = 3'b100;
            S_GREEN:  light = 3'b001;
            S_YELLOW: light = 3'b010;
            default:  light = 3'b100;
        endcase
    end

endmodule
