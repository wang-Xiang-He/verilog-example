// ============================================================
//  W15-3：按鍵計數（上板子一定會踩到的三個坑）
//  重點：★ 這是第 6 週去彈跳 + 第 7 週同步器的【實戰版】
//
//  外部訊號進 FPGA 一定要做三件事，少一件就會出怪事：
//    1. 兩級同步器  → 避免亞穩態（第 7 週 03_cdc_sync）
//    2. 去彈跳      → 機械按鍵會抖（第 6 週 03_debounce）
//    3. 邊緣偵測    → 按著不放不能一直加
// ============================================================
`timescale 1ns / 1ps

module button_counter #(
    parameter CLK_HZ    = 12_000_000,
    parameter DEBOUNCE_MS = 10          // 去彈跳時間：10 毫秒
) (
    input  wire       clk,
    input  wire       btn,        // ★ 外部按鍵，非同步、會彈跳
    input  wire       btn2,       // 第二顆：切換方向
    output wire [7:0] led,        // 8 顆 LED 顯示計數值
    output wire       busy
);

    localparam integer DEB_TICKS = (CLK_HZ / 1000) * DEBOUNCE_MS;

    function integer clog2;
        input integer v;
        integer i;
        begin
            clog2 = 1;
            for (i = v - 1; i > 1; i = i >> 1) clog2 = clog2 + 1;
        end
    endfunction

    localparam DW = clog2(DEB_TICKS);

    // ========================================================
    //  ★ 第 1 坑：亞穩態
    //
    //  btn 是外部訊號，和 clk 完全沒有關係。
    //  如果它剛好在時脈邊緣前後那一瞬間變化，正反器會進入
    //  「既不是 0 也不是 1」的亞穩態，輸出可能震盪一段時間。
    //
    //  解法：串兩級正反器。第一級可能亞穩，但它有一整個時脈週期
    //        可以穩定下來，第二級收到的就是乾淨的值。
    //
    //  ⚠️ 這不是「降低機率」，是把失效時間拉長到幾百年一次。
    //     少了它，你的電路會【偶爾】亂跳，而且完全查不出原因。
    // ========================================================
    reg btn_s0 = 0, btn_s1 = 0;
    reg btn2_s0 = 0, btn2_s1 = 0;

    always @(posedge clk) begin
        btn_s0  <= btn;      btn_s1  <= btn_s0;
        btn2_s0 <= btn2;     btn2_s1 <= btn2_s0;
    end

    // ========================================================
    //  ★ 第 2 坑：機械彈跳
    //
    //  按鍵是金屬片碰撞，按一次會在幾毫秒內【彈跳幾十次】。
    //  直接拿來數，按一下會加十幾。
    //
    //  解法：訊號要連續穩定 DEB_TICKS 拍，才承認它變了。
    // ========================================================
    reg [DW-1:0] deb_cnt = 0;
    reg          btn_clean = 0;

    always @(posedge clk) begin
        if (btn_s1 == btn_clean) begin
            deb_cnt <= 0;                       // 和目前一樣，計數歸零
        end else if (deb_cnt == DEB_TICKS - 1) begin
            btn_clean <= btn_s1;                // 穩定夠久了，承認它
            deb_cnt   <= 0;
        end else begin
            deb_cnt <= deb_cnt + 1'b1;
        end
    end

    assign busy = (deb_cnt != 0);   // 正在確認中（接 LED 可以看到）

    // ========================================================
    //  ★ 第 3 坑：按著不放
    //
    //  btn_clean 在你按住的期間會一直是 1，
    //  直接拿去當致能，計數器會每個時脈加一次 —— 一秒加一千兩百萬。
    //
    //  解法：邊緣偵測，只在「從 0 變 1 的那一拍」動作。
    // ========================================================
    reg btn_prev = 0;
    always @(posedge clk) btn_prev <= btn_clean;

    wire btn_rise = btn_clean & ~btn_prev;

    // ========================================================
    //  計數器本體（前面三關都過了才輪到它）
    // ========================================================
    reg [7:0] count = 0;

    always @(posedge clk) begin
        if (btn_rise)
            count <= btn2_s1 ? (count - 1'b1) : (count + 1'b1);
    end

    assign led = count;

endmodule

//  ---- 模擬 ----
//  iverilog -o sim.out 03_button.v 03_button_tb.v
//  vvp sim.out
//  gtkwave 03_button.gtkw
//
//  ---- 產生 bitstream ----
//  build.bat 03_button button_counter
