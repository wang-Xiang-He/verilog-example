`timescale 1ns / 1ps

//  ★ 這個測試平台的用意是【示範模擬抓不到那個 bug】。
//    先用一般的讀寫交錯測試（會通過），
//    再用「連續寫滿」的定向測試（才會抓到）。
module formal_tb;
    localparam DW = 8, AW = 3, DEPTH = 8;

    reg        clk, rst_n, wr, rd;
    reg  [7:0] din;
    wire [7:0] dout_b, dout_f;
    wire       empty_b, full_b, empty_f, full_f;
    wire [3:0] count_b, count_f;

    integer i, err_b, err_f;

    fifo_buggy #(.DW(DW), .AW(AW)) u_bug (
        .clk(clk), .rst_n(rst_n), .wr(wr), .rd(rd), .din(din),
        .dout(dout_b), .empty(empty_b), .full(full_b), .count(count_b));

    fifo_fixed #(.DW(DW), .AW(AW)) u_fix (
        .clk(clk), .rst_n(rst_n), .wr(wr), .rd(rd), .din(din),
        .dout(dout_f), .empty(empty_f), .full(full_f), .count(count_f));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, formal_tb);
        clk = 0; rst_n = 0; wr = 0; rd = 0; din = 0;
        err_b = 0; err_f = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   形式驗證：為什麼「測很多組都對」不夠");
        $display("  ============================================================");

        // ============================================================
        $display("");
        $display("  ===== 一、一般的隨機讀寫測試（2000 拍）=====");
        $display("");
        for (i = 0; i < 2000; i = i + 1) begin
            @(negedge clk);
            wr  = $random;
            rd  = $random;
            din = $random;
            #1;
            if (count_b > DEPTH) err_b = err_b + 1;
            if (count_f > DEPTH) err_f = err_f + 1;
        end
        wr = 0; rd = 0;

        $display("   buggy 版：count 超出容量 %0d 次", err_b);
        $display("   fixed 版：count 超出容量 %0d 次", err_f);
        $display("");
        if (err_b == 0) begin
            $display("   ★★ buggy 版【通過了】隨機測試 —— 但它是錯的。");
            $display("      隨機讓 wr/rd 各半機率為 1，FIFO 很少被連續灌滿，");
            $display("      剛好避開了觸發條件。");
        end else begin
            $display("   這次 2000 拍夠長，隨機測試抓到了。");
            $display("");
            $display("   ⚠️ 但這是【運氣】，不是驗證方法可靠：");
            $display("     - 換一組亂數種子、或只跑 200 拍，很可能就抓不到");
            $display("     - 就算抓到，它只告訴你「有時候會爆」，");
            $display("       不會告訴你【什麼條件下】會爆");
            $display("     - 而且你得先寫對 assert（count > 容量）才看得見，");
            $display("       如果測試平台只比對讀出來的資料，根本不會發現");
        end

        // ============================================================
        $display("");
        $display("  ===== 二、★ 定向測試：連續寫 9 次，一次都不讀 =====");
        $display("");
        rst_n = 0; @(negedge clk); rst_n = 1;
        @(negedge clk);

        $display("   第幾次寫 | buggy: count full | fixed: count full");
        $display("   ---------+-------------------+-------------------");
        rd = 0;
        for (i = 1; i <= 9; i = i + 1) begin
            @(negedge clk);
            wr = 1; din = 8'hA0 + i[7:0];
            #1;
            $display("      %0d     |    %2d     %0d      |    %2d     %0d",
                     i, count_b, full_b, count_f, full_f);
        end
        @(negedge clk); wr = 0;
        #1;

        $display("");
        $display("   最終：buggy count = %0d，fixed count = %0d（容量只有 %0d）",
                 count_b, count_f, DEPTH);
        $display("");
        if (count_b > DEPTH) begin
            $display("   ★★ 抓到了！buggy 版的 count 變成 %0d，超過容量 %0d。",
                     count_b, DEPTH);
            $display("      因為 full 晚一拍才跳起來，第 %0d 筆沒被擋住，", DEPTH+1);
            $display("      直接把第 1 筆蓋掉了。");
        end else begin
            $display("   [X] 這次沒抓到，換個測試序列再試");
        end
        $display("");
        $display("   fixed 版停在 count = %0d，full 準時擋住了。", count_f);

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   ★★★ 這就是形式驗證存在的理由");
        $display("");
        $display("     隨機測試：跑了 2000 拍，抓到 %0d 次 —— 運氣問題", err_b);
        $display("     定向測試：抓到了，但【前提是你要先想到】要這樣測");
        $display("     形式驗證：不到 1 秒，自己把觸發序列算出來");
        $display("");
        $display("   跑跑看：");
        $display("     04_formal.bat");
        $display("");
        $display("   它會做兩件事：");
        $display("     1. 對 buggy 版跑 bmc  → FAIL，產生反例波形");
        $display("     2. 對 fixed 版跑 prove → PASS，k-induction 證明成功");
        $display("");
        $display("   ★ 「successful proof by k-induction」的意思是：");
        $display("     不是「測了 20 拍都沒事」，");
        $display("     是【數學證明】在任何長度、任何輸入序列下都不會違反。");
        $display("     這是模擬永遠做不到的事。");
        $display("");
        $display("   ⚠️ 但形式驗證也有極限：");
        $display("     1. 只證明你【寫出來的那些 assert】，沒寫的不會幫你檢查");
        $display("     2. 狀態空間太大時證明器會跑不完（記憶體、CPU 都會爆）");
        $display("     3. assume 寫太寬鬆 → 證明的是一個不存在的世界");
        $display("        （例如忘了 assume 初始要 reset，結果都在證垃圾）");
        $display("");
        $display("     所以實務上是【模擬 + 形式驗證並用】，不是二選一。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
