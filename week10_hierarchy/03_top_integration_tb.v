`timescale 1ns / 1ps

module top_integration_tb;
    reg        clk, rst_n, btn_raw, dir_up, preset, log_rd;
    reg  [3:0] preset_val;

    wire [3:0] count;
    wire [6:0] seg;
    wire       btn_clean, tick;
    wire [7:0] log_dout;
    wire       log_empty, log_full;
    wire [3:0] log_count;

    integer i, j, err, tick_count;

    top_integration uut (
        .clk(clk), .rst_n(rst_n),
        .btn_raw(btn_raw), .dir_up(dir_up),
        .preset(preset), .preset_val(preset_val),
        .log_rd(log_rd),
        .count(count), .seg(seg), .btn_clean(btn_clean), .tick(tick),
        .log_dout(log_dout), .log_empty(log_empty),
        .log_full(log_full), .log_count(log_count)
    );

    always #5 clk = ~clk;

    //  模擬一次真實的按鍵：先抖動，穩定一段時間，放開時再抖動
    task press_button;
        begin
            //  按下時抖 6 次
            for (j = 0; j < 6; j = j + 1) begin
                @(negedge clk); btn_raw = 1;
                @(negedge clk); btn_raw = 0;
            end
            //  穩定按住
            @(negedge clk); btn_raw = 1;
            repeat (12) @(negedge clk);
            //  放開時再抖幾次
            for (j = 0; j < 4; j = j + 1) begin
                @(negedge clk); btn_raw = 0;
                @(negedge clk); btn_raw = 1;
            end
            @(negedge clk); btn_raw = 0;
            repeat (12) @(negedge clk);
        end
    endtask

    //  數這次按鍵產生了幾個 tick
    always @(posedge clk) if (tick) tick_count = tick_count + 1;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, top_integration_tb);
        clk = 0; rst_n = 0; btn_raw = 0; dir_up = 1;
        preset = 0; preset_val = 0; log_rd = 0;
        err = 0; tick_count = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   系統整合：按鍵計數器");
        $display("   debounce → edge_detect → counter → seg7 + FIFO");
        $display("  ============================================================");

        // ============================================================
        $display("");
        $display("  ===== 一、★ 一次按鍵只能產生一個 tick =====");
        $display("");
        $display("   按鍵訊號會抖 6 次、放開再抖 4 次，總共 20 個邊緣。");
        $display("   如果沒有去彈跳，計數器會一次跳 10 格。");
        $display("");
        tick_count = 0;
        press_button;
        $display("   這次按鍵產生的 tick 數 = %0d", tick_count);
        if (tick_count == 1) $display("   ★ 正確：抖了 20 個邊緣，只算 1 次");
        else begin
            $display("   [X] 應該只有 1 個");
            err = err + 1;
        end
        $display("   計數器現在 = %0d", count);

        // ============================================================
        $display("");
        $display("  ===== 二、連按 5 次（上數）=====");
        $display("");
        $display("   次數 | count | seg (gfedcba) | 顯示");
        $display("   -----+-------+---------------+------");
        for (i = 0; i < 5; i = i + 1) begin
            press_button;
            $display("     %0d  |   %0d   |    %b    |  %0d", i+1, count, seg, count);
        end
        if (count !== 4'd6) begin
            $display("   [X] 按了 6 次應該是 6，得到 %0d", count);
            err = err + 1;
        end

        // ============================================================
        $display("");
        $display("  ===== 三、切換成下數，再按 3 次 =====");
        $display("");
        dir_up = 0;
        for (i = 0; i < 3; i = i + 1) begin
            press_button;
            $display("   按第 %0d 次 → count = %0d", i+1, count);
        end
        if (count !== 4'd3) begin
            $display("   [X] 應該是 3，得到 %0d", count);
            err = err + 1;
        end

        // ============================================================
        $display("");
        $display("  ===== 四、預載 =====");
        $display("");
        @(negedge clk); preset_val = 4'd9; preset = 1;
        @(negedge clk); preset = 0;
        @(negedge clk);
        $display("   預載 9 → count = %0d，seg = %b", count, seg);
        if (count !== 4'd9) err = err + 1;

        // ============================================================
        $display("");
        $display("  ===== 五、讀出 FIFO 裡的操作記錄 =====");
        $display("");
        $display("   FIFO 裡有 %0d 筆記錄", log_count);
        $display("");
        $display("   第幾筆 | dir | count | 意義");
        $display("   -------+-----+-------+------------------");
        i = 0;
        while (!log_empty && i < 16) begin
            $display("     %2d   |  %0d  |   %0d   | 按鍵時方向=%0d 計數=%0d",
                     i, log_dout[4], log_dout[3:0], log_dout[4], log_dout[3:0]);
            @(negedge clk); log_rd = 1;
            @(negedge clk); log_rd = 0;
            i = i + 1;
        end

        // ============================================================
        $display("");
        $display("  ------------------------------------------------------------");
        if (err == 0) $display("   ★ 全部通過，0 個錯");
        else          $display("   [X] 有 %0d 項不符", err);

        $display("");
        $display("   ★★ 這個範例真正的重點不是功能，是【頂層長什麼樣子】：");
        $display("");
        $display("     打開 03_top_integration.v 看 top_integration 模組 ——");
        $display("     裡面【一行 always 都沒有，一個 assign 都沒有】，");
        $display("     只有五個模組實例和它們之間的接線。");
        $display("");
        $display("     這是好的頂層應有的樣子。頂層一旦開始寫邏輯，");
        $display("     就代表你有東西放錯層了。");
        $display("");
        $display("   ★ GTKWave 練習：");
        $display("     左邊的階層樹點開 uut → u_deb / u_edge / u_cnt / u_seg / u_log，");
        $display("     把 btn_raw、u_deb.sync1、btn_clean、tick、count 排在一起，");
        $display("     可以看到一個訊號【穿過三層模組】的完整過程。");
        $display("");
        #20 $finish;
    end
endmodule
