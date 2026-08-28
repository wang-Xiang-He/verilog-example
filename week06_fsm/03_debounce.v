// ============================================================
//  W6-3：按鍵去彈跳 —— 狀態機的實用經典
//  重點：實體按鍵按一下，電氣上其實會抖動幾十次
// ============================================================
`timescale 1ns / 1ps

module debounce #(
    parameter STABLE_CNT = 8        // 要連續穩定幾拍才承認
)(
    input  wire clk,
    input  wire rst,
    input  wire btn_raw,            // 會抖動的原始訊號
    output reg  btn_clean,          // 乾淨的訊號
    output reg  btn_pulse           // 按下瞬間的單拍脈衝
);

    localparam IDLE = 2'd0, WAIT = 2'd1;

    reg [1:0] state;
    reg [7:0] cnt;
    reg       btn_sync1, btn_sync2;   // 雙 FF 同步器（第 7 週細講）

    // 先同步，避免亞穩態
    always @(posedge clk) begin
        btn_sync1 <= btn_raw;
        btn_sync2 <= btn_sync1;
    end

    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            cnt       <= 0;
            btn_clean <= 1'b0;
            btn_pulse <= 1'b0;
        end else begin
            btn_pulse <= 1'b0;                 // 預設不發脈衝

            case (state)
                IDLE: begin
                    if (btn_sync2 != btn_clean) begin
                        state <= WAIT;
                        cnt   <= 0;
                    end
                end

                WAIT: begin
                    if (btn_sync2 != btn_clean) begin
                        if (cnt >= STABLE_CNT - 1) begin
                            btn_clean <= btn_sync2;
                            if (btn_sync2) btn_pulse <= 1'b1;   // 只在按下時發
                            state <= IDLE;
                        end else begin
                            cnt <= cnt + 1'b1;
                        end
                    end else begin
                        state <= IDLE;         // 抖回去了 → 放棄，重新等
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
