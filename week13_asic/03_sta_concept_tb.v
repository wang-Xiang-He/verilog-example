`timescale 1ns / 1ps

module sta_concept_tb;
    reg        clk, rst_n;
    reg  [7:0] a, b;
    wire [7:0]  sp;
    wire [8:0]  mp;
    wire [15:0] lp;

    integer i, err;

    sta_demo uut (.clk(clk), .rst_n(rst_n), .a(a), .b(b),
                  .short_path(sp), .medium_path(mp), .long_path(lp));

    always #5 clk = ~clk;

    //  ---- STA 算式示範用的參數（取自 tiny_cells.lib）----
    real Tcq, Tsetup, Thold, Tskew, Tlogic, Tperiod, slack;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, sta_concept_tb);
        clk = 0; rst_n = 0; a = 0; b = 0; err = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   靜態時序分析 (STA)：最高時脈是【算】出來的，不是量的");
        $display("  ============================================================");

        // ============================================================
        $display("");
        $display("  ===== 一、先確認功能（模擬只能做到這件事）=====");
        $display("");
        for (i = 0; i < 500; i = i + 1) begin
            @(negedge clk);
            a = $random; b = $random;
            @(negedge clk);
            if (sp !== (uut.a_r ^ uut.b_r)) err = err + 1;
            if (mp !== (uut.a_r + uut.b_r)) err = err + 1;
            if (lp !== (uut.a_r * uut.b_r)) err = err + 1;
        end
        if (err == 0) $display("   ★ 500 組全部正確");
        else          $display("   [X] 有 %0d 處錯", err);
        $display("");
        $display("   ⚠️ 但這【完全沒有告訴你能跑多快】。");
        $display("      模擬是用理想的 10ns 週期跑的，");
        $display("      真實電路能不能在 10ns 內穩定下來，模擬看不出來。");

        // ============================================================
        $display("");
        $display("  ===== 二、★ setup 檢查的算式 =====");
        $display("");
        $display("   一條「正反器 → 組合邏輯 → 正反器」的路徑：");
        $display("");
        $display("      ┌─────┐  Tcq   ┌──────────┐ Tlogic  ┌─────┐");
        $display("      │ FF1 │───────→│ 組合邏輯 │────────→│ FF2 │");
        $display("      └─────┘        └──────────┘         └─────┘");
        $display("         ↑                                    ↑");
        $display("         └────────────── clk ─────────────────┘");
        $display("");
        $display("   要成立的條件：");
        $display("");
        $display("      Tcq + Tlogic + Tsetup  ≤  Tperiod - Tskew");
        $display("");
        $display("   多出來的餘裕叫【時序裕度 slack】：");
        $display("");
        $display("      slack = (Tperiod - Tskew) - (Tcq + Tlogic + Tsetup)");
        $display("");
        $display("      slack ≥ 0  →  ★ 過了（PASS）");
        $display("      slack ＜ 0  →  ★ 沒過（VIOLATION），時脈要降或路徑要縮");

        // ============================================================
        $display("");
        $display("  ===== 三、用 tiny_cells.lib 的數字實際算一次 =====");
        $display("");
        Tcq    = 0.10;    // DFF 的 clk-to-Q（元件庫寫的）
        Tsetup = 0.05;    // DFF 的 setup 時間
        Thold  = 0.02;    // DFF 的 hold 時間
        Tskew  = 0.05;    // 時脈偏移（假設值）

        $display("   從 tiny_cells.lib 查到的參數：");
        $display("     Tcq (clk-to-Q)  = %0.2f ns", Tcq);
        $display("     Tsetup          = %0.2f ns", Tsetup);
        $display("     Thold           = %0.2f ns", Thold);
        $display("     Tskew（假設）    = %0.2f ns", Tskew);
        $display("");

        //  ---- 情況 1：短路徑 ----
        Tlogic  = 0.12;                  // 一顆 XOR2
        Tperiod = 1.00;                  // 1 GHz
        slack   = (Tperiod - Tskew) - (Tcq + Tlogic + Tsetup);
        $display("   ---- 短路徑（一顆 XOR，Tlogic=%0.2f）在 1 GHz 下 ----", Tlogic);
        $display("     slack = (%0.2f - %0.2f) - (%0.2f + %0.2f + %0.2f) = %+0.2f ns",
                 Tperiod, Tskew, Tcq, Tlogic, Tsetup, slack);
        if (slack >= 0) $display("     → ★ PASS，還有 %0.2f ns 餘裕", slack);
        else            $display("     → [X] VIOLATION，差 %0.2f ns", -slack);

        //  ---- 情況 2：長路徑 ----
        $display("");
        Tlogic  = 8.00;                  // 一整顆乘法器
        Tperiod = 1.00;
        slack   = (Tperiod - Tskew) - (Tcq + Tlogic + Tsetup);
        $display("   ---- 長路徑（一顆乘法器，Tlogic=%0.2f）在 1 GHz 下 ----", Tlogic);
        $display("     slack = (%0.2f - %0.2f) - (%0.2f + %0.2f + %0.2f) = %+0.2f ns",
                 Tperiod, Tskew, Tcq, Tlogic, Tsetup, slack);
        if (slack >= 0) $display("     → ★ PASS");
        else            $display("     → [X] VIOLATION，差 %0.2f ns —— 時脈太快了", -slack);

        //  ---- 反推最高時脈 ----
        $display("");
        Tperiod = Tcq + Tlogic + Tsetup + Tskew;
        $display("   ---- 那這條路徑最快能跑多少？ ----");
        $display("     最小週期 = Tcq + Tlogic + Tsetup + Tskew");
        $display("              = %0.2f + %0.2f + %0.2f + %0.2f = %0.2f ns",
                 Tcq, Tlogic, Tsetup, Tskew, Tperiod);
        $display("     ★ 最高時脈 = 1000 / %0.2f = %0.1f MHz", Tperiod, 1000.0/Tperiod);
        $display("");
        $display("   ★★ 這就是 STA 在做的事 —— 不跑模擬，純粹用查表加減乘除，");
        $display("      算出【每一條路徑】的 slack，找出最小的那一條。");
        $display("");
        $display("   ★ 對照一下：上面【手算】出來的是 %0.1f MHz，", 1000.0/Tperiod);
        $display("     而 03_sta_concept.bat 用 nextpnr【實測】path_long 是 116.05 MHz。");
        $display("     兩個數字幾乎一樣 —— 這不是巧合，因為 nextpnr 做的就是同一件事：");
        $display("     把路徑上每一顆元件的延遲查表加起來。");
        $display("     （我這裡假設 Tlogic=8ns 是憑經驗抓的，能抓這麼準算運氣好）");

        // ============================================================
        $display("");
        $display("  ===== 四、hold 檢查（另一半，而且更麻煩）=====");
        $display("");
        $display("   setup 問的是：資料【夠快到】嗎？");
        $display("   hold  問的是：資料【留得夠久】嗎？");
        $display("");
        $display("      Tcq + Tlogic  ≥  Thold + Tskew");
        $display("");
        Tlogic = 0.01;
        $display("   ⚠️ 注意 hold 檢查【和時脈週期無關】！");
        $display("      路徑【太短】反而會違規：");
        $display("        Tcq(%0.2f) + Tlogic(%0.2f) = %0.2f",
                 Tcq, Tlogic, Tcq + Tlogic);
        $display("        Thold(%0.2f) + Tskew(%0.2f) = %0.2f",
                 Thold, Tskew, Thold + Tskew);
        if ((Tcq + Tlogic) >= (Thold + Tskew))
            $display("        → PASS");
        else
            $display("        → [X] HOLD VIOLATION");
        $display("");
        $display("   ★ setup 沒過 → 把時脈調慢就好（還有救）");
        $display("     hold  沒過 → ★★ 調時脈【沒有用】，晶片直接報廢");
        $display("");
        $display("     所以 hold violation 在 ASIC 是最可怕的錯誤之一。");
        $display("     修法：在太短的路徑上【故意插入緩衝器】把它拉長。");
        $display("     （聽起來很荒謬，但這是標準作法，叫 hold fixing）");

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   實測（跑 03_sta_concept.bat）：");
        $display("");
        $display("     path_short   8 顆 XOR       655.31 MHz");
        $display("     path_medium  8 位元加法器   244.20 MHz");
        $display("     path_long    8x8 乘法器     116.05 MHz");
        $display("     sta_demo     三條全在一起   ★ 約等於 path_long");
        $display("");
        $display("   ★★ 最後一行：sta_demo 裡有一條 655 MHz 的路徑，");
        $display("      但整個模組只能跑 116 MHz。");
        $display("");
        $display("      整個設計的速度由【最慢的那一條】決定，");
        $display("      那條就叫【關鍵路徑 Critical Path】。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
