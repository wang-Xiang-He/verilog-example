`timescale 1ns / 1ps

module freq_div_tb;
    reg  clk, rst_n;
    wire div2, div4, div8, div16, div5, div5_50;

    integer i;
    integer hi5, lo5, tick_cnt;
    time    t_prev, t_now;

    freq_div uut (.clk(clk), .rst_n(rst_n),
                  .div2(div2), .div4(div4), .div8(div8), .div16(div16),
                  .div5(div5), .div5_50(div5_50));

    always #5 clk = ~clk;      // 週期 10ns → 100MHz

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, freq_div_tb);
        clk = 0; rst_n = 0;
        hi5 = 0; lo5 = 0; tick_cnt = 0;

        #12 rst_n = 1;

        // ============================================================
        $display("");
        $display("  ===== 一、除以 2 的次方：一顆計數器全包 =====");
        $display("");
        $display("   拍 | cnt  | div2 div4 div8 div16");
        $display("   ---+------+----------------------");
        for (i = 0; i < 17; i = i + 1) begin
            @(negedge clk);
            $display("   %2d | %b |  %0d    %0d    %0d    %0d",
                     i, uut.cnt, div2, div4, div8, div16);
        end
        $display("");
        $display("   ★ 看 cnt 那一欄就懂了：div2 就是 cnt[0]、div4 是 cnt[1]...");
        $display("     除以 2 的次方【完全不用做電路】，接線就好。");
        $display("     所以能用 2 的次方就用，別去湊奇數。");

        // ============================================================
        $display("");
        $display("  ===== 二、除以 5：一拍寬的 tick 脈衝 =====");
        $display("");
        $display("   拍 | cnt5 | div5");
        $display("   ---+------+-----");
        rst_n = 0; @(negedge clk); rst_n = 1;
        for (i = 0; i < 16; i = i + 1) begin
            @(negedge clk);
            $display("   %2d |  %0d   |  %0d %s", i, uut.cnt5, div5,
                     div5 ? "  <== tick" : "");
            if (div5) tick_cnt = tick_cnt + 1;
        end
        $display("");
        $display("   16 拍裡出現 %0d 個 tick（大約每 5 拍一個）", tick_cnt);
        $display("   ★ 工作週期只有 1/5，不是 50%% —— 但拿來當「每 5 拍動作一次」");
        $display("     的致能訊號剛剛好，實務上大多數場合要的就是這個。");

        // ============================================================
        $display("");
        $display("  ===== 三、★ 除以 5 又要 50%% 工作週期 =====");
        $display("");
        rst_n = 0; @(negedge clk); rst_n = 1;
        #1;

        //  量高電位和低電位各佔多少 ns
        for (i = 0; i < 200; i = i + 1) begin
            #1;
            if (div5_50) hi5 = hi5 + 1;
            else         lo5 = lo5 + 1;
        end
        $display("   量 200ns：高電位 %0d ns，低電位 %0d ns", hi5, lo5);
        $display("   工作週期 = %0d%%", (hi5 * 100) / (hi5 + lo5));
        $display("");

        //  量週期
        t_prev = 0;
        @(posedge div5_50); t_prev = $time;
        @(posedge div5_50); t_now  = $time;
        //  ★ 注意：%0t 印出來是【時間精度單位】(這裡是 ps)，不是 ns。
        //    要印 ns 就直接用 %0d 印相減的結果（timescale 的時間單位是 1ns）。
        $display("   相鄰兩次上升緣相隔 %0d ns", t_now - t_prev);
        $display("   輸入時脈週期 10ns → %0d / 10 = 除以 %0d  ★",
                 t_now - t_prev, (t_now - t_prev) / 10);

        $display("");
        $display("   ------------------------------------------------------------");
        $display("   怎麼做到的（這題考試很愛考）：");
        $display("     5 拍沒辦法平均切成兩半（2.5 : 2.5）");
        $display("     → 做兩份除 5 電路，一份用 posedge、一份用 negedge");
        $display("     → 兩份差【半個時脈週期】");
        $display("     → 把它們 OR 起來，就補出中間那半拍");
        $display("     → 高 2.5 拍、低 2.5 拍，剛好 50%%");
        $display("");
        $display("   ⚠️ 但實務上要小心：同時用 posedge 和 negedge 的電路");
        $display("      對時脈的責任週期很敏感，FPGA 上不建議這樣做。");
        $display("      要 50%% 的奇數除頻，比較常見的作法是先乘頻再除。");
        $display("");
        #20 $finish;
    end
endmodule
