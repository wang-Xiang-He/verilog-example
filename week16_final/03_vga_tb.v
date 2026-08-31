`timescale 1ns / 1ps

// ============================================================
//  期末專題 第 3 題 —— 自動判分測試平台
//  配分：水平時序 30 + 垂直時序 30 + video_on 20 + 圖樣 20 = 100 分
// ============================================================
module vga_tb;
    localparam H_VISIBLE = 640, H_FRONT = 16, H_SYNC = 96, H_BACK = 48;
    localparam V_VISIBLE = 480, V_FRONT = 10, V_SYNC = 2,  V_BACK = 33;
    localparam H_TOTAL = 800, V_TOTAL = 525;

    reg        clk, rst_n;
    wire       hsync, vsync, video_on, frame_start;
    wire [9:0] px, py;
    wire [2:0] rgb;
    wire       p_hsync, p_vsync;

    integer i, score;
    integer h_period, h_low, v_low_lines, on_count;
    integer t0, t1, err;
    integer white_cnt, black_cnt, blank_bad;

    vga_sync uut (.clk(clk), .rst_n(rst_n),
                  .hsync(hsync), .vsync(vsync), .video_on(video_on),
                  .pixel_x(px), .pixel_y(py), .frame_start(frame_start));

    vga_pattern uut2 (.clk(clk), .rst_n(rst_n),
                      .hsync(p_hsync), .vsync(p_vsync), .rgb(rgb));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, vga_tb);
        clk = 0; rst_n = 0; score = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   期末專題 第 3 題：VGA 訊號產生器 640x480@60Hz");
        $display("  ============================================================");
        $display("");
        $display("   規格：水平 %0d+%0d+%0d+%0d = %0d",
                 H_VISIBLE, H_FRONT, H_SYNC, H_BACK, H_TOTAL);
        $display("         垂直 %0d+%0d+%0d+%0d = %0d",
                 V_VISIBLE, V_FRONT, V_SYNC, V_BACK, V_TOTAL);

        // ========================================================
        //  測試 1：水平時序（30 分）
        // ========================================================
        $display("");
        $display("  ===== 測試 1：水平時序（30 分）=====");
        $display("");

        //  (a) hsync 週期要是 800 個時脈（15 分）
        //  先等到一個 hsync 下降緣
        t0 = 0; t1 = 0;
        i = 0;
        while (hsync !== 1'b1 && i < 4000) begin @(posedge clk); i = i + 1; end
        i = 0;
        while (hsync !== 1'b0 && i < 4000) begin @(posedge clk); i = i + 1; end
        t0 = $time;
        h_low = 0;
        while (hsync === 1'b0 && i < 8000) begin
            @(posedge clk); h_low = h_low + 1; i = i + 1;
        end
        //  等下一個下降緣
        while (hsync !== 1'b0 && i < 8000) begin @(posedge clk); i = i + 1; end
        t1 = $time;
        h_period = (t1 - t0) / 10;

        if (h_period == H_TOTAL) begin
            score = score + 15;
            $display("   [O] hsync 週期 = %0d 個時脈                    (15/15)", h_period);
        end else
            $display("   [X] hsync 週期 = %0d，應該是 %0d              (0/15)",
                     h_period, H_TOTAL);

        //  (b) hsync 低電位寬度要是 96（15 分）
        if (h_low == H_SYNC) begin
            score = score + 15;
            $display("   [O] hsync 低電位寬度 = %0d                     (15/15)", h_low);
        end else begin
            $display("   [X] hsync 低電位寬度 = %0d，應該是 %0d         (0/15)",
                     h_low, H_SYNC);
            if (h_low == H_TOTAL - H_SYNC)
                $display("       ★ 你的 hsync 極性寫【反】了 —— 應該是低準位有效");
        end

        // ========================================================
        //  測試 2：垂直時序（30 分）
        // ========================================================
        $display("");
        $display("  ===== 測試 2：垂直時序（30 分）=====");
        $display("");
        $display("   （要跑完一整張畫面 %0d 個時脈，請稍等）", H_TOTAL*V_TOTAL);
        $display("");

        //  數一張畫面裡 vsync 為低的【掃描線數】
        rst_n = 0; @(negedge clk); rst_n = 1;
        i = 0;
        while (!frame_start && i < H_TOTAL*V_TOTAL*2) begin
            @(posedge clk); i = i + 1;
        end

        v_low_lines = 0;
        on_count    = 0;
        for (i = 0; i < H_TOTAL*V_TOTAL; i = i + 1) begin
            @(posedge clk);
            //  每行開頭看一次 vsync
            if (px == 10'd0 && vsync === 1'b0) v_low_lines = v_low_lines + 1;
            if (video_on) on_count = on_count + 1;
        end

        if (v_low_lines == V_SYNC) begin
            score = score + 30;
            $display("   [O] vsync 低電位持續 %0d 條掃描線               (30/30)", v_low_lines);
        end else begin
            $display("   [X] vsync 低電位持續 %0d 條，應該是 %0d         (0/30)",
                     v_low_lines, V_SYNC);
            if (v_low_lines == V_TOTAL - V_SYNC)
                $display("       ★ vsync 極性也寫反了");
            else if (v_low_lines == 0)
                $display("       ★ vsync 完全沒有拉低過 —— v_cnt 有在動嗎？");
        end

        // ========================================================
        //  測試 3：video_on（20 分）
        // ========================================================
        $display("");
        $display("  ===== 測試 3：可見區域（20 分）=====");
        $display("");

        if (on_count == H_VISIBLE * V_VISIBLE) begin
            score = score + 20;
            $display("   [O] 一張畫面 video_on 為 1 共 %0d 個像素        (20/20)", on_count);
            $display("       = %0d x %0d，完全正確", H_VISIBLE, V_VISIBLE);
        end else
            $display("   [X] video_on 為 1 共 %0d 個，應該是 %0d        (0/20)",
                     on_count, H_VISIBLE*V_VISIBLE);

        // ========================================================
        //  測試 4：棋盤格圖樣（20 分）
        // ========================================================
        $display("");
        $display("  ===== 測試 4：棋盤格圖樣（20 分）=====");
        $display("");

        rst_n = 0; @(negedge clk); rst_n = 1;
        i = 0;
        while (!frame_start && i < H_TOTAL*V_TOTAL*2) begin
            @(posedge clk); i = i + 1;
        end

        white_cnt = 0; black_cnt = 0; blank_bad = 0; err = 0;
        for (i = 0; i < H_TOTAL*V_TOTAL; i = i + 1) begin
            @(posedge clk);
            if (video_on) begin
                if (rgb === 3'b111) white_cnt = white_cnt + 1;
                else if (rgb === 3'b000) black_cnt = black_cnt + 1;
                else err = err + 1;
            end else begin
                //  ★ 消隱期間一定要送黑色
                if (rgb !== 3'b000) blank_bad = blank_bad + 1;
            end
        end

        $display("   可見區：白 %0d 像素、黑 %0d 像素", white_cnt, black_cnt);
        $display("   消隱區送出非黑色的次數：%0d", blank_bad);
        $display("");

        //  8x6 格，每格 80x80。黑白格數：x 有 8 格、y 有 6 格
        //  (cx[0]^cy[0]) → 一半一半 = 640*480/2 = 153600
        if (blank_bad == 0 && white_cnt == 153600 && black_cnt == 153600) begin
            score = score + 20;
            $display("   [O] 棋盤格黑白各 %0d 像素，消隱區乾淨           (20/20)", white_cnt);
        end else begin
            $display("   [X] 圖樣不正確                                  (0/20)");
            if (blank_bad > 0)
                $display("       ★ 消隱期間送了顏色 —— 螢幕會認不出訊號");
            if (white_cnt + black_cnt != 307200)
                $display("       ★ rgb 出現了 000/111 以外的值");
        end

        // ========================================================
        $display("");
        $display("  ============================================================");
        $display("     總分  %0d / 100", score);
        $display("");
        if (score == 100) begin
            $display("     ★★★ 滿分！這個設計【接上真的螢幕就會顯示畫面】。");
            $display("");
            $display("     VGA 時序產生器是所有顯示相關設計的基礎 ——");
            $display("     加上一塊畫面記憶體就是顯示卡，");
            $display("     加上字型 ROM 就是終端機。");
        end else if (score >= 60)
            $display("     ★ 時序大致對了，剩下的細節再修。");
        else if (score >= 30)
            $display("     >>> 先確認兩個計數器：h_cnt 每拍動、v_cnt 只在換行時動。");
        else
            $display("     >>> 從 h_cnt 開始，先讓 hsync 週期變成 800。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end

    initial begin
        #40_000_000;
        $display("");
        $display("   [!] 模擬逾時");
        $finish;
    end
endmodule
