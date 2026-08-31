`timescale 1ns / 1ps

module button_tb;
    reg        clk, btn, btn2;
    wire [7:0] led;
    wire       busy;

    integer i, j;

    //  ★ CLK_HZ 調成 1000、去彈跳 2ms → 只要 2 拍，模擬跑得快
    button_counter #(.CLK_HZ(1000), .DEBOUNCE_MS(2)) uut (
        .clk(clk), .btn(btn), .btn2(btn2), .led(led), .busy(busy));

    always #5 clk = ~clk;

    //  模擬真實按鍵：按下抖、穩定、放開再抖
    task press;
        begin
            for (j = 0; j < 5; j = j + 1) begin
                @(negedge clk); btn = 1;
                @(negedge clk); btn = 0;
            end
            @(negedge clk); btn = 1;
            repeat (8) @(negedge clk);
            for (j = 0; j < 3; j = j + 1) begin
                @(negedge clk); btn = 0;
                @(negedge clk); btn = 1;
            end
            @(negedge clk); btn = 0;
            repeat (8) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, button_tb);
        clk = 0; btn = 0; btn2 = 0;

        $display("");
        $display("  ============================================================");
        $display("   按鍵計數：上板子一定會踩到的三個坑");
        $display("  ============================================================");

        // ============================================================
        $display("");
        $display("  ===== 一、一次按鍵 = 一次計數 =====");
        $display("");
        $display("   每次按鍵訊號會抖 16 個邊緣。");
        $display("   如果沒做去彈跳，計數器會一次跳 8 格。");
        $display("");
        $display("   按第幾次 | led (計數值)");
        $display("   ---------+--------------");
        for (i = 1; i <= 5; i = i + 1) begin
            press;
            $display("      %0d     |     %0d", i, led);
        end
        $display("");
        if (led == 8'd5)
            $display("   ★ 按 5 次得到 5 —— 三道防線都有效");
        else
            $display("   [X] 得到 %0d，應該是 5", led);

        // ============================================================
        $display("");
        $display("  ===== 二、按著不放，不能一直加 =====");
        $display("");
        @(negedge clk); btn = 1;
        repeat (60) @(negedge clk);       // 按住 60 拍
        $display("   按住 60 拍後 led = %0d", led);
        @(negedge clk); btn = 0;
        repeat (10) @(negedge clk);
        $display("   放開後      led = %0d", led);
        if (led == 8'd6)
            $display("   ★ 只加了 1 —— 邊緣偵測有效");
        else
            $display("   [X] 得到 %0d，應該是 6", led);

        // ============================================================
        $display("");
        $display("  ===== 三、btn2 切換方向（下數）=====");
        $display("");
        btn2 = 1;
        for (i = 1; i <= 3; i = i + 1) begin
            press;
            $display("   下數第 %0d 次 → led = %0d", i, led);
        end

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   ★★ 三道防線，缺一不可：");
        $display("");
        $display("     1. 兩級同步器（btn → btn_s0 → btn_s1）");
        $display("        btn 和 clk 完全沒關係，可能在時脈邊緣正中間變化。");
        $display("        那會讓正反器進入【亞穩態】—— 既不是 0 也不是 1，");
        $display("        輸出震盪一段時間。");
        $display("        ⚠️ 這不是理論問題，是真的會發生的物理現象。");
        $display("           少了同步器，電路會【偶爾】亂跳，而且查不出原因。");
        $display("");
        $display("     2. 去彈跳（btn_s1 → btn_clean）");
        $display("        機械按鍵是金屬片碰撞，按一次會在幾毫秒內彈跳幾十次。");
        $display("        直接數的話按一下會加十幾。");
        $display("");
        $display("     3. 邊緣偵測（btn_clean → btn_rise）");
        $display("        btn_clean 在按住期間一直是 1，");
        $display("        直接當致能的話，12MHz 下按住一秒會加一千兩百萬。");
        $display("");
        $display("   ★ 這三件事在【每一個】外部輸入上都要做：");
        $display("     按鍵、開關、感測器、另一顆晶片來的訊號…");
        $display("     只要不是同一個時脈域來的，就要走這三關。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
