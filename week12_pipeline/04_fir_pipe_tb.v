`timescale 1ns / 1ps

module fir_pipe_tb;
    localparam DW = 8;

    reg              clk, rst_n, vld_in;
    reg  [DW-1:0]    x, c0, c1, c2, c3;
    wire [2*DW+1:0]  y_comb, y_pipe;
    wire             v_comb, v_pipe;

    integer i, err;
    reg [DW-1:0] hist [0:511];
    integer      hn;
    reg [2*DW+1:0] expect;

    fir_comb #(.DW(DW)) u_comb (
        .clk(clk), .rst_n(rst_n), .vld_in(vld_in), .x(x),
        .c0(c0), .c1(c1), .c2(c2), .c3(c3), .y(y_comb), .vld_out(v_comb));

    fir_pipe #(.DW(DW)) u_pipe (
        .clk(clk), .rst_n(rst_n), .vld_in(vld_in), .x(x),
        .c0(c0), .c1(c1), .c2(c2), .c3(c3), .y(y_pipe), .vld_out(v_pipe));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, fir_pipe_tb);
        clk = 0; rst_n = 0; vld_in = 0; x = 0;
        //  一組簡單的低通係數
        c0 = 8'd1; c1 = 8'd2; c2 = 8'd2; c3 = 8'd1;
        err = 0; hn = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   4 階 FIR 濾波器：單週期 vs 三級管線");
        $display("   y[n] = 1*x[n] + 2*x[n-1] + 2*x[n-2] + 1*x[n-3]");
        $display("  ============================================================");

        // ============================================================
        $display("");
        $display("  ===== 一、送一個脈衝進去（脈衝響應）=====");
        $display("");
        $display("   ★ 送一個孤立的 1 進去，輸出應該剛好把係數【依序吐出來】：");
        $display("     1, 2, 2, 1 —— 這是驗證 FIR 對不對最快的方法。");
        $display("");
        $display("   拍 |  x  | comb  | pipe  | 說明");
        $display("   ---+-----+-------+-------+------------------");

        for (i = 0; i < 10; i = i + 1) begin
            @(negedge clk);
            vld_in = 1;
            x = (i == 0) ? 8'd1 : 8'd0;      // 只在第 0 拍送 1
            #1;
            $display("   %2d |  %0d  | %5d | %5d |", i, x, y_comb, y_pipe);
        end
        @(negedge clk); vld_in = 0; x = 0;
        for (i = 0; i < 4; i = i + 1) begin
            #1;
            $display("    - |  -  | %5d | %5d | 排空", y_comb, y_pipe);
            @(negedge clk);
        end

        $display("");
        $display("   ★ comb 那一欄依序出現 1 2 2 1 —— 係數被完整吐出來了。");
        $display("     pipe 那一欄一樣是 1 2 2 1，只是【晚 2 拍】。");

        // ============================================================
        $display("");
        $display("  ===== 二、送方波，看它被「平滑」掉 =====");
        $display("");
        $display("   FIR 低通濾波器的作用就是把突然的變化磨平");
        $display("");
        $display("   拍 |  x  | y_comb | 圖示");
        $display("   ---+-----+--------+--------------------");
        rst_n = 0; @(negedge clk); rst_n = 1;
        for (i = 0; i < 14; i = i + 1) begin
            @(negedge clk);
            vld_in = 1;
            x = (i >= 3 && i < 9) ? 8'd10 : 8'd0;
            #1;
            $write("   %2d |  %2d | %5d  | ", i, x, y_comb);
            //  用星號畫個簡單的長條圖
            if      (y_comb >= 55) $display("**********");
            else if (y_comb >= 45) $display("*********");
            else if (y_comb >= 35) $display("*******");
            else if (y_comb >= 25) $display("*****");
            else if (y_comb >= 15) $display("***");
            else if (y_comb >=  5) $display("*");
            else                   $display("");
        end
        $display("");
        $display("   ★ 輸入是方方正正的一塊，輸出的邊緣變成【斜坡】——");
        $display("     那就是低通濾波在做的事。");

        // ============================================================
        $display("");
        $display("  ===== 三、兩版本結果比對：連續 300 筆 =====");
        $display("");
        rst_n = 0; @(negedge clk); rst_n = 1;
        hn = 0; err = 0;
        for (i = 0; i < 300; i = i + 1) begin
            @(negedge clk);
            vld_in = 1;
            x = $random;
            hist[hn] = x; hn = hn + 1;
            #1;
            //  comb 版延遲 2 拍、pipe 版延遲 4 拍，
            //  所以 pipe 現在的輸出應該等於 comb 兩拍前的輸出。
            //  最簡單的比法：直接自己算應該是多少。
            if (i >= 5) begin
                //  comb 在第 i 拍輸出的是第 (i-2) 筆的結果
                expect = hist[i-2]*c0 + hist[i-3]*c1 + hist[i-4]*c2 + hist[i-5]*c3;
                if (y_comb !== expect) begin
                    err = err + 1;
                    if (err <= 3)
                        $display("   [X] 第 %0d 拍 comb=%0d 應該 %0d", i, y_comb, expect);
                end
            end
            if (i >= 7) begin
                //  pipe 在第 i 拍輸出的是第 (i-4) 筆的結果
                expect = hist[i-4]*c0 + hist[i-5]*c1 + hist[i-6]*c2 + hist[i-7]*c3;
                if (y_pipe !== expect) begin
                    err = err + 1;
                    if (err <= 3)
                        $display("   [X] 第 %0d 拍 pipe=%0d 應該 %0d", i, y_pipe, expect);
                end
            end
        end
        vld_in = 0;

        if (err == 0) $display("   ★ 兩個版本 300 筆全部正確");
        else          $display("   [X] 共 %0d 處不符", err);

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   ★★ 為什麼 FIR 是管線最經典的應用？");
        $display("");
        $display("     因為訊號處理的資料是【一直來、不會停】的：");
        $display("       音訊 48kHz、影像每秒幾千萬個像素、通訊每秒幾百 Mbit。");
        $display("");
        $display("     這種場合【延遲多幾拍完全無所謂】——");
        $display("     音訊晚 4 個取樣點 = 晚 0.08 毫秒，人耳聽不出來。");
        $display("     但【每秒能處理多少筆】是死的要求，差一點就做不到。");
        $display("");
        $display("     反過來說，如果是「按一個鍵、算一次、馬上要答案」，");
        $display("     切管線就完全沒有意義，只是白白多花正反器。");
        $display("");
        $display("   跑 04_fir_pipe.bat 看兩版本的最高時脈差多少");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
