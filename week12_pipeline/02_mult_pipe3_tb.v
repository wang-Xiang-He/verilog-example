`timescale 1ns / 1ps

module mult_pipe3_tb;
    reg         clk, rst_n, vld_in;
    reg  [7:0]  a, b;
    wire [15:0] p;
    wire        vld_out;

    integer i, err, first_out, out_count;

    //  記錄送進去的東西，用來對答案
    reg [15:0] expect_q [0:63];
    integer    wr_idx, rd_idx;

    mult_pipe3 uut (.clk(clk), .rst_n(rst_n), .vld_in(vld_in),
                    .a(a), .b(b), .p(p), .vld_out(vld_out));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, mult_pipe3_tb);
        clk = 0; rst_n = 0; vld_in = 0; a = 0; b = 0;
        err = 0; first_out = -1; out_count = 0;
        wr_idx = 0; rd_idx = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   三級管線乘法器");
        $display("  ============================================================");

        // ============================================================
        $display("");
        $display("  ===== 一、量延遲：送一筆，幾拍後出來？ =====");
        $display("");
        @(negedge clk); a = 8'd12; b = 8'd10; vld_in = 1;
        @(negedge clk); vld_in = 0; a = 0; b = 0;

        $display("   拍 | v0 v1 v2 vld_out |   p   | 資料現在走到哪一級");
        $display("   ---+------------------+-------+--------------------");
        for (i = 0; i < 6; i = i + 1) begin
            $display("   %2d |  %0d  %0d  %0d    %0d    | %5d |",
                     i, uut.v0, uut.v1, uut.v2, vld_out, p);
            if (vld_out && first_out < 0) first_out = i;
            @(negedge clk);
        end
        $display("");
        $display("   ★ 看 v0 → v1 → v2 → vld_out 那個 1 【一格一格往右走】");
        $display("     那就是資料在管線裡前進的樣子。");
        $display("");
        $display("   延遲 (latency) = %0d 拍  ← 比單週期版多 2 拍", first_out + 1);
        $display("   12 x 10 = 120，得到 %0d", 120);

        // ============================================================
        $display("");
        $display("  ===== 二、★★ 管線的填充與排空 =====");
        $display("");
        $display("   連續灌 6 筆，然後停止，看管線怎麼填滿又怎麼排空");
        $display("");
        $display("   拍 | 送進去  | v0 v1 v2 out |   p   | 管線狀態");
        $display("   ---+---------+--------------+-------+--------------------");

        for (i = 1; i <= 6; i = i + 1) begin
            @(negedge clk);
            vld_in = 1; a = i[7:0]; b = 8'd10;
            expect_q[wr_idx] = i * 10; wr_idx = wr_idx + 1;
            #1;
            if (i <= 3)
                $display("   %2d |  %0d x 10 |  %0d  %0d  %0d   %0d  | %5d | 填充中（還沒滿）",
                         i, i, uut.v0, uut.v1, uut.v2, vld_out, p);
            else
                $display("   %2d |  %0d x 10 |  %0d  %0d  %0d   %0d  | %5d | ★ 滿載：4 筆同時在跑",
                         i, i, uut.v0, uut.v1, uut.v2, vld_out, p);
        end

        @(negedge clk); vld_in = 0; a = 0; b = 0;
        for (i = 0; i < 5; i = i + 1) begin
            #1;
            $display("    - |   --    |  %0d  %0d  %0d   %0d  | %5d | 排空中",
                     uut.v0, uut.v1, uut.v2, vld_out, p);
            @(negedge clk);
        end

        $display("");
        $display("   ★★ 中間那幾拍，管線裡【同時有 4 筆資料】在不同級前進。");
        $display("      這就是為什麼延遲變長了，吞吐量卻沒有變差 ——");
        $display("      還是每拍出一筆。");

        // ============================================================
        $display("");
        $display("  ===== 三、吞吐量：和單週期版一樣是每拍 1 筆 =====");
        $display("");
        //  先把前一節殘留在管線裡的資料排空，計數才準
        vld_in = 0;
        repeat (6) @(negedge clk);
        out_count = 0;
        fork
            begin : feeder
                //  ★ vld_in 要和 a/b 在【同一個時間點】設定。
                //    如果先把 vld_in 拉高才進迴圈，第一個正緣會吃到
                //    還沒更新的舊 a/b，就會多算一筆。
                for (i = 0; i < 20; i = i + 1) begin
                    @(negedge clk);
                    vld_in = 1; a = i[7:0] + 8'd1; b = 8'd3;
                end
                @(negedge clk); vld_in = 0;
            end
            begin : counter_blk
                repeat (26) begin
                    @(posedge clk);
                    if (vld_out) out_count = out_count + 1;
                end
            end
        join
        $display("   灌進去 20 筆，26 拍內收到 %0d 筆", out_count);
        $display("   ★ 每拍 1 筆，和單週期版完全一樣。");
        $display("     管線【不會讓吞吐量變好】，它讓【時脈可以拉高】，");
        $display("     時脈高了，同樣的「每拍 1 筆」每秒就變多筆。");

        // ============================================================
        $display("");
        $display("  ===== 四、正確性：連續 500 筆全自動比對 =====");
        wr_idx = 0; rd_idx = 0; err = 0;
        @(negedge clk); vld_in = 1;
        for (i = 0; i < 500; i = i + 1) begin
            a = $random; b = $random;
            expect_q[i % 64] = a * b;
            @(negedge clk);
            //  ★ 這裡的偏移量要小心數：
            //    迴圈每一圈只經過【一個】時脈正緣，
            //    而 a/b 是在 negedge 設定、下一個 posedge 才被吃進級 0。
            //    所以在本圈的 @(negedge) 之後，p 上面是第 (i-3) 筆的答案。
            //    （管線深度 4 級，但第 1 級在本圈就吃進去了，所以是 4-1=3）
            if (i >= 3) begin
                if (p !== expect_q[(i - 3) % 64]) begin
                    err = err + 1;
                    if (err <= 3)
                        $display("   [X] 第 %0d 筆：得到 %0d，應該是 %0d",
                                 i - 3, p, expect_q[(i-3) % 64]);
                end
            end
        end
        vld_in = 0;

        $display("");
        if (err == 0) $display("   ★ 500 筆全部正確（含管線對齊）");
        else          $display("   [X] 有 %0d 筆錯", err);

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   ★★ 管線設計最常犯的錯：");
        $display("");
        $display("     資料延遲了 4 拍，但忘了把 valid 也延遲 4 拍。");
        $display("     結果：答案是【對的】，但送出去的【時間點錯了】。");
        $display("");
        $display("     本檔用 v0 → v1 → v2 → vld_out 把 valid 一起推，");
        $display("     這叫「控制訊號要和資料對齊」。");
        $display("     每加一級管線，所有跟著資料走的控制訊號都要多推一格。");
        $display("");
        $display("   下一步：03_compare.bat 實測兩者的最高時脈");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
