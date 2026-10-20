`timescale 1ns/1ps

// =====================================================================
// Traffic_Light：紅綠燈控制器，示範 `define 與 parameter（講義第 5、16、17 頁）
//   講義只有程式片段（中間用「略」帶過），這裡依片段補成可以模擬的完整電路：
//     紅燈亮 9 個時脈 → 綠燈亮 6 個時脈 → 黃燈亮 1 個時脈 → 回到紅燈 ...
// =====================================================================

// `define 巨集名稱 內容：編譯前把程式裡的 `巨集名稱 換成「內容」（純文字取代）
//   使用時前面要加反引號：`RED_Light_Time
//   行尾【不要】加分號：寫成 `define RED_Light_Time 9; 的話，取代後會多一個 ; 而編譯錯誤
`define RED_Light_Time      9   // 紅燈亮的時間倍值
`define GREEN_Light_Time    6   // 綠燈亮的時間倍值
`define YELLOW_Light_Time   1   // 黃燈亮的時間倍值

module Traffic_Light (
    input      Clock,
    input      Reset,
    output reg RED,
    output reg GREEN,
    output reg YELLOW
);
    // parameter：有限狀態機（FSM）的內部狀態，各個狀態的編碼
    parameter RED_Light    = 2'b00,
              GREEN_Light  = 2'b01,
              YELLOW_Light = 2'b10;

    reg [1:0] state;
    reg [3:0] Count_In;         // 目前這個燈已經亮了幾個時脈（從 1 開始數）

    always @(posedge Clock) begin
        if (Reset) begin        // 電路重置動作
            state    <= RED_Light;      // 初始狀態設為：RED_Light（紅燈）
            RED      <= 1'b1;           // 紅燈亮
            GREEN    <= 1'b0;
            YELLOW   <= 1'b0;
            Count_In <= 1;              // 重新計數，設為 1
        end
        else begin
            case (state)
                RED_Light:                              // 目前狀態為：紅燈
                    if (Count_In == `RED_Light_Time) begin      // 紅燈維持 RED_Light_Time 個時脈
                        state    <= GREEN_Light;
                        RED      <= 1'b0;
                        GREEN    <= 1'b1;
                        Count_In <= 1;                  // 重新計數
                    end
                    else
                        Count_In <= Count_In + 1;

                GREEN_Light:                            // 目前狀態為：綠燈
                    if (Count_In == `GREEN_Light_Time) begin
                        state    <= YELLOW_Light;
                        GREEN    <= 1'b0;
                        YELLOW   <= 1'b1;
                        Count_In <= 1;
                    end
                    else
                        Count_In <= Count_In + 1;

                YELLOW_Light:                           // 目前狀態為：黃燈
                    if (Count_In == `YELLOW_Light_Time) begin
                        state    <= RED_Light;
                        YELLOW   <= 1'b0;
                        RED      <= 1'b1;
                        Count_In <= 1;
                    end
                    else
                        Count_In <= Count_In + 1;

                default: begin                          // 2'b11 不是合法狀態 → 回到紅燈
                    state    <= RED_Light;
                    RED      <= 1'b1;
                    GREEN    <= 1'b0;
                    YELLOW   <= 1'b0;
                    Count_In <= 1;
                end
            endcase
        end
    end
    // ※ 講義用阻隔式 =（state = RED_Light;），這裡是時脈觸發的 always，改用非阻隔式 <=
endmodule
