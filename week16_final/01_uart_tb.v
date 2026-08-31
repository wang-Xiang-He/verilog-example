`timescale 1ns / 1ps

// ============================================================
//  期末專題 第 1 題 —— 自動判分測試平台
//  配分：鮑率產生器 20 + 發送器 40 + 接收器 40 = 100 分
// ============================================================
module uart_tb;
    localparam TICKS = 16;          // 模擬用小值，跑得快

    reg clk, rst_n;

    //  ---- 鮑率產生器 ----
    reg  bg_en;
    wire bg_tick;

    //  ---- 發送器 ----
    reg        tx_send;
    reg  [7:0] tx_data;
    wire       tx_line, tx_busy;

    //  ---- 接收器（直接接發送器的輸出，做迴路測試）----
    wire [7:0] rx_data;
    wire       rx_valid, rx_ferr;

    integer i, j;
    integer score_baud, score_tx, score_rx, total;
    integer tick_count, gap, last_tick;
    reg [7:0] got;
    integer   bitpos;
    reg       ok;

    baud_gen #(.TICKS(TICKS)) u_bg (
        .clk(clk), .rst_n(rst_n), .en(bg_en), .tick(bg_tick));

    uart_tx #(.TICKS(TICKS)) u_tx (
        .clk(clk), .rst_n(rst_n), .send(tx_send), .data(tx_data),
        .tx(tx_line), .busy(tx_busy));

    uart_rx #(.TICKS(TICKS)) u_rx (
        .clk(clk), .rst_n(rst_n), .rx(tx_line),
        .data_out(rx_data), .valid(rx_valid), .frame_err(rx_ferr));

    always #5 clk = ~clk;

    //  從 tx 線上自己解碼一個位元組（不依賴受測的接收器）
    //  ★ 一定要有逾時保護：如果受測的發送器根本不動，
    //    @(negedge tx_line) 會永遠等下去，整份測試就卡死了，
    //    交白卷的人連分數表都看不到。
    task sniff_byte;
        output [7:0] b;
        output       good;
        integer k, guard;
        begin
            good = 1'b1;
            b    = 8'hXX;
            guard = 0;
            while (tx_line !== 1'b0 && guard < TICKS * 30) begin
                @(posedge clk); guard = guard + 1;
            end
            if (guard >= TICKS * 30) begin
                good = 1'b0;                          // 逾時：發送器沒動
            end else begin
                repeat (TICKS + TICKS/2) @(posedge clk);  // 對齊到 d0 中央
                for (k = 0; k < 8; k = k + 1) begin
                    b[k] = tx_line;
                    repeat (TICKS) @(posedge clk);
                end
                if (tx_line !== 1'b1) good = 1'b0;    // 停止位元要是 1
            end
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, uart_tb);
        clk = 0; rst_n = 0;
        bg_en = 0; tx_send = 0; tx_data = 0;
        score_baud = 0; score_tx = 0; score_rx = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   期末專題 第 1 題：UART 收發器");
        $display("   TICKS = %0d（每個位元 %0d 個時脈）", TICKS, TICKS);
        $display("  ============================================================");

        // ========================================================
        //  第 1 部分：鮑率產生器（20 分）
        // ========================================================
        $display("");
        $display("  ===== 第 1 部分：鮑率產生器（20 分）=====");
        $display("");

        //  (a) en=0 時 tick 必須一直是 0（5 分）
        bg_en = 0;
        tick_count = 0;
        repeat (TICKS * 3) begin
            @(posedge clk);
            if (bg_tick) tick_count = tick_count + 1;
        end
        if (tick_count == 0) begin
            score_baud = score_baud + 5;
            $display("   [O] en=0 時 tick 保持 0                        (5/5)");
        end else
            $display("   [X] en=0 時竟然出現 %0d 個 tick               (0/5)", tick_count);

        //  (b) en=1 時要週期性出現 tick（10 分）
        bg_en = 1;
        tick_count = 0;
        repeat (TICKS * 5) begin
            @(posedge clk);
            if (bg_tick) tick_count = tick_count + 1;
        end
        if (tick_count == 5) begin
            score_baud = score_baud + 10;
            $display("   [O] en=1 時 %0d 拍內出現 5 個 tick             (10/10)", TICKS*5);
        end else
            $display("   [X] %0d 拍內出現 %0d 個 tick，應該是 5        (0/10)",
                     TICKS*5, tick_count);

        //  (c) tick 只能高一拍（5 分）
        ok = 1'b1;
        for (i = 0; i < TICKS * 3; i = i + 1) begin
            @(posedge clk);
            if (bg_tick) begin
                @(posedge clk);
                if (bg_tick) ok = 1'b0;      // 連續兩拍都高 → 錯
            end
        end
        if (ok) begin
            score_baud = score_baud + 5;
            $display("   [O] tick 每次只高一拍                          (5/5)");
        end else
            $display("   [X] tick 連續高了兩拍以上                      (0/5)");

        bg_en = 0;
        $display("");
        $display("   第 1 部分小計：%0d / 20", score_baud);

        // ========================================================
        //  第 2 部分：發送器（40 分）
        // ========================================================
        $display("");
        $display("  ===== 第 2 部分：發送器（40 分）=====");
        $display("");

        //  (a) 閒置時 tx 要是 1（5 分）
        repeat (5) @(posedge clk);
        if (tx_line === 1'b1 && tx_busy === 1'b0) begin
            score_tx = score_tx + 5;
            $display("   [O] 閒置時 tx=1、busy=0                        (5/5)");
        end else
            $display("   [X] 閒置時 tx=%b busy=%b，應該是 1 和 0        (0/5)",
                     tx_line, tx_busy);

        //  (b) 送單一位元組（15 分）
        fork
            begin
                @(negedge clk); tx_data = 8'h41; tx_send = 1;
                @(negedge clk); tx_send = 0;
            end
            sniff_byte(got, ok);
        join
        if (got === 8'h41 && ok) begin
            score_tx = score_tx + 15;
            $display("   [O] 送 0x41 收到 0x%h，停止位元正確            (15/15)", got);
        end else begin
            $display("   [X] 送 0x41 收到 0x%h，停止位元 %s             (0/15)",
                     got, ok ? "正確" : "錯誤");
            $display("       常見錯誤：LSB/MSB 順序寫反、tx 沒上正反器");
        end

        //  (c) 連送多個位元組（15 分）
        j = 0;
        for (i = 0; i < 5; i = i + 1) begin
            case (i)
                0: tx_data = 8'h00;
                1: tx_data = 8'hFF;
                2: tx_data = 8'h55;
                3: tx_data = 8'hAA;
                4: tx_data = 8'h5A;
            endcase
            //  ★ 一定要先等上一筆送完。busy 期間發 send 會被
            //    （正確地）忽略，然後這一輪就抓不到東西了。
            begin : idle_wait
                integer g; g = 0;
                while (tx_busy && g < TICKS*30) begin @(posedge clk); g = g + 1; end
            end
            repeat (TICKS * 2) @(negedge clk);

            fork
                begin
                    @(negedge clk); tx_send = 1;
                    @(negedge clk); tx_send = 0;
                end
                sniff_byte(got, ok);
            join
            if (got === tx_data && ok) j = j + 1;
            else $display("       送 0x%h 收到 0x%h", tx_data, got);
        end
        if (j == 5) begin
            score_tx = score_tx + 15;
            $display("   [O] 邊界值 00/FF/55/AA/5A 全部正確             (15/15)");
        end else
            $display("   [X] 5 組邊界值只對了 %0d 組                    (0/15)", j);

        //  (d) busy 期間要忽略 send（5 分）
        begin : idle_wait3
            integer g; g = 0;
            while (tx_busy && g < TICKS*30) begin @(posedge clk); g = g + 1; end
        end
        repeat (TICKS * 2) @(negedge clk);

        fork
            begin
                @(negedge clk); tx_data = 8'h11; tx_send = 1;
                @(negedge clk); tx_send = 0;
                repeat (TICKS) @(negedge clk);
                //  傳送中再戳一次 send，應該被忽略
                tx_data = 8'h99; tx_send = 1;
                @(negedge clk); tx_send = 0;
            end
            sniff_byte(got, ok);
        join
        if (got === 8'h11) begin
            score_tx = score_tx + 5;
            $display("   [O] busy 期間的 send 被正確忽略                (5/5)");
        end else
            $display("   [X] busy 期間被打斷，收到 0x%h 而不是 0x11     (0/5)", got);

        begin : drain1
            integer g; g = 0;
            while (tx_busy && g < TICKS*30) begin @(posedge clk); g = g + 1; end
        end
        repeat (TICKS * 2) @(negedge clk);

        $display("");
        $display("   第 2 部分小計：%0d / 40", score_tx);

        // ========================================================
        //  第 3 部分：接收器（40 分）—— 迴路測試
        // ========================================================
        $display("");
        $display("  ===== 第 3 部分：接收器（40 分）=====");
        $display("");
        $display("   把發送器的輸出直接接到接收器的輸入（迴路測試）");
        $display("");

        //  (a) 收單一位元組（15 分）
        fork
            begin
                @(negedge clk); tx_data = 8'h3C; tx_send = 1;
                @(negedge clk); tx_send = 0;
            end
            begin : wait_v1
                integer t;
                t = 0;
                while (!rx_valid && t < TICKS * 20) begin
                    @(posedge clk); t = t + 1;
                end
            end
        join
        if (rx_valid && rx_data === 8'h3C) begin
            score_rx = score_rx + 15;
            $display("   [O] 收到 0x%h，valid 有拉起來                  (15/15)", rx_data);
        end else if (!rx_valid)
            $display("   [X] valid 從來沒有拉起來                       (0/15)");
        else
            $display("   [X] 收到 0x%h，應該是 0x3C                     (0/15)", rx_data);

        repeat (TICKS * 3) @(negedge clk);

        //  (b) valid 只能高一拍（5 分）
        //  (c) 連收多個位元組（20 分）
        j = 0;
        ok = 1'b1;
        for (i = 0; i < 6; i = i + 1) begin
            case (i)
                0: tx_data = 8'h00;
                1: tx_data = 8'hFF;
                2: tx_data = 8'h01;
                3: tx_data = 8'h80;
                4: tx_data = 8'h55;
                5: tx_data = 8'hAA;
            endcase
            begin : idle_wait2
                integer g; g = 0;
                while (tx_busy && g < TICKS*30) begin @(posedge clk); g = g + 1; end
            end
            repeat (TICKS * 2) @(negedge clk);

            fork
                begin
                    @(negedge clk); tx_send = 1;
                    @(negedge clk); tx_send = 0;
                end
                begin : wait_v2
                    integer t;
                    t = 0;
                    while (!rx_valid && t < TICKS * 20) begin
                        @(posedge clk); t = t + 1;
                    end
                    if (rx_valid) begin
                        if (rx_data === tx_data) j = j + 1;
                        else $display("       送 0x%h 收到 0x%h", tx_data, rx_data);
                        @(posedge clk);
                        if (rx_valid) ok = 1'b0;      // 第二拍還高 → 錯
                    end
                end
            join
            begin : drain2
                integer g; g = 0;
                while (tx_busy && g < TICKS*30) begin @(posedge clk); g = g + 1; end
            end
            repeat (TICKS * 2) @(negedge clk);
        end

        if (ok) begin
            score_rx = score_rx + 5;
            $display("   [O] valid 每次只高一拍                         (5/5)");
        end else
            $display("   [X] valid 連續高了兩拍以上                     (0/5)");

        if (j == 6) begin
            score_rx = score_rx + 20;
            $display("   [O] 6 組邊界值全部收對                         (20/20)");
        end else
            $display("   [X] 6 組只收對 %0d 組                          (0/20)", j);

        $display("");
        $display("   第 3 部分小計：%0d / 40", score_rx);

        // ========================================================
        total = score_baud + score_tx + score_rx;
        $display("");
        $display("  ============================================================");
        $display("     鮑率產生器  %2d / 20", score_baud);
        $display("     發送器      %2d / 40", score_tx);
        $display("     接收器      %2d / 40", score_rx);
        $display("     -----------------------");
        $display("     總分        %2d / 100", total);
        $display("");
        if (total == 100)
            $display("     ★★★ 滿分！這題等於做出一個真正能用的 UART IP。");
        else if (total >= 80)
            $display("     ★ 及格，剩下的部分再檢查一次。");
        else if (total >= 40)
            $display("     >>> 主要架構有了，細節再修。");
        else
            $display("     >>> 先從鮑率產生器開始，那是最單純的一塊。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end

    //  防止測試卡住
    initial begin
        #2_000_000;
        $display("");
        $display("   [!] 模擬逾時 —— 通常是狀態機卡在某個狀態出不來");
        $display("       檢查：tick 有沒有正確產生？狀態轉換條件對嗎？");
        $finish;
    end
endmodule
