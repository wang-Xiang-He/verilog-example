`timescale 1ns / 1ps

module blink_tb;
    reg  clk;
    wire led, led_fast, heartbeat;

    integer i, toggles;
    reg     prev_led;

    //  ★ 模擬時把 CLK_HZ 改成很小的數字。
    //    真的用 12_000_000 的話，要模擬一千兩百萬拍才看得到 LED 翻一次。
    //    這是 FPGA 設計【一定要參數化】的實際理由。
    blink #(.CLK_HZ(200), .BLINK_HZ(1)) uut (
        .clk(clk), .led(led), .led_fast(led_fast), .heartbeat(heartbeat));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, blink_tb);
        clk = 0; toggles = 0; prev_led = 0;

        $display("");
        $display("  ============================================================");
        $display("   LED 閃爍：第一個會產生真 bitstream 的設計");
        $display("  ============================================================");
        $display("");
        $display("   模擬參數：CLK_HZ=200, BLINK_HZ=1");
        $display("   → HALF_PERIOD = 200/(2*1) = 100 拍翻一次");
        $display("   （上板時是 CLK_HZ=12000000，要 600 萬拍才翻一次）");
        $display("");
        $display("   拍   | led  led_fast  heartbeat");
        $display("   -----+--------------------------");

        for (i = 0; i < 420; i = i + 1) begin
            @(negedge clk);
            if (i % 20 == 0)
                $display("   %4d |  %0d      %0d          %0d", i, led, led_fast, heartbeat);
            if (led !== prev_led) toggles = toggles + 1;
            prev_led = led;
        end

        $display("");
        $display("   420 拍內 led 翻了 %0d 次（預期約 4 次）", toggles);
        if (toggles >= 3 && toggles <= 5)
            $display("   ★ 正確");
        else
            $display("   [X] 次數不對");

        $display("");
        $display("  ============================================================");
        $display("   ★ 這個設計要注意的三件事：");
        $display("");
        $display("     1. 【沒有 reset】");
        $display("        FPGA 上電時，bitstream 會把正反器設成宣告的初始值");
        $display("        （reg cnt = 0）。所以閃燈這種東西可以省掉 reset 線。");
        $display("        ⚠️ 這招【只在 FPGA 有效】，ASIC 一定要有 reset。");
        $display("");
        $display("     2. 【位元寬度用 clog2 算出來】");
        $display("        寫死 [31:0] 的話，改 CLK_HZ 就可能不夠用或浪費資源。");
        $display("");
        $display("     3. 【led_fast 是免費的】");
        $display("        直接拿計數器的最高位當輸出，一顆閘都不用");
        $display("        （第 3 週 15_freq_div 學的）。");
        $display("");
        $display("   下一步：build.bat 01_blink blink");
        $display("   會產生 01_blink.bin —— 真正可以燒進晶片的檔案。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
