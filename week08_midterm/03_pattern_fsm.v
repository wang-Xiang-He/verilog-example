// ============================================================
//  期中考 第 3 題：密碼鎖狀態機
//  難度：★★★   考的是：第 6 週（三段式狀態機）+ 綜合應用
// ============================================================
`timescale 1ns / 1ps

//  規格：
//    使用者每拍輸入一個 2 位元的按鍵 key（只有 key_valid=1 那拍才算數）
//    正確密碼是依序按：1, 2, 3, 0
//
//    按對完整四碼 → unlock 在「按下最後一碼的那個時脈邊緣」拉高，
//                    並且只維持一拍（所以 unlock 要用暫存器輸出）
//    中途按錯      → 回到起點重來（但要注意：按錯的那個鍵，
//                    如果它剛好是密碼的第一碼，要算成新的開始）
//    rst=1        → 回到起點
//
//  提示：
//    狀態就是「已經對了幾碼」：S0(還沒) S1 S2 S3
//    用三段式寫法

module pattern_fsm (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] key,
    input  wire       key_valid,
    output reg        unlock,
    output wire [1:0] state_out
);

    localparam S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3;

    reg [1:0] state, next_state;
    assign state_out = state;

    // ★★★ 在這裡寫你的答案 ★★★

    // ===== 第 1 段：狀態暫存器 =====
    always @(posedge clk) begin
        if (rst) state <= S0;
        else     state <= next_state;      // ← 這段已經給你了
    end

    // ===== 第 2 段：下一狀態邏輯 =====
    always @(*) begin
        next_state = state;    // ← 把下面補完
    end

    // ===== 第 3 段：輸出邏輯（★這題要用暫存器輸出，才能「只拉高一拍」）=====
    always @(posedge clk) begin
        unlock <= 1'b0;        // ← 把這段補完
    end

endmodule
