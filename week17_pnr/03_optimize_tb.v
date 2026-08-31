`timescale 1ns / 1ps

module optimize_tb;
    reg         clk, rst_n;
    reg  [7:0]  d0,d1,d2,d3,d4,d5,d6,d7;
    wire [10:0] s_lin, s_tree, s_pipe;

    integer i, err_t, err_p;
    integer exp_q [0:15];

    sum_linear u_lin  (.clk(clk), .rst_n(rst_n),
        .d0(d0),.d1(d1),.d2(d2),.d3(d3),.d4(d4),.d5(d5),.d6(d6),.d7(d7), .sum(s_lin));
    sum_tree   u_tree (.clk(clk), .rst_n(rst_n),
        .d0(d0),.d1(d1),.d2(d2),.d3(d3),.d4(d4),.d5(d5),.d6(d6),.d7(d7), .sum(s_tree));
    sum_pipe   u_pipe (.clk(clk), .rst_n(rst_n),
        .d0(d0),.d1(d1),.d2(d2),.d3(d3),.d4(d4),.d5(d5),.d6(d6),.d7(d7), .sum(s_pipe));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, optimize_tb);
        clk = 0; rst_n = 0;
        d0=0;d1=0;d2=0;d3=0;d4=0;d5=0;d6=0;d7=0;
        err_t = 0; err_p = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   把 8 個數字加起來：三種寫法，先確認結果一樣");
        $display("  ============================================================");

        $display("");
        $display("  ===== 一、三種寫法算出來要一模一樣 =====");
        $display("");
        $display("   拍 |  linear  tree  |  pipe（晚 2 拍）");
        $display("   ---+----------------+------------------");

        for (i = 0; i < 12; i = i + 1) begin
            @(negedge clk);
            d0 = i+1;  d1 = i+2;  d2 = i+3;  d3 = i+4;
            d4 = i+5;  d5 = i+6;  d6 = i+7;  d7 = i+8;
            exp_q[i % 16] = (i+1)+(i+2)+(i+3)+(i+4)+(i+5)+(i+6)+(i+7)+(i+8);
            @(negedge clk);
            $display("   %2d |  %5d  %5d  |  %5d", i, s_lin, s_tree, s_pipe);
            if (s_lin !== s_tree) err_t = err_t + 1;
        end

        $display("");
        if (err_t == 0) $display("   ★ linear 和 tree 完全一致（本來就該一樣，只是括號不同）");
        else            $display("   [X] linear 和 tree 有 %0d 拍不同", err_t);

        // ============================================================
        $display("");
        $display("  ===== 二、隨機 500 組驗證 =====");
        $display("");
        err_t = 0; err_p = 0;
        for (i = 0; i < 500; i = i + 1) begin
            @(negedge clk);
            d0=$random; d1=$random; d2=$random; d3=$random;
            d4=$random; d5=$random; d6=$random; d7=$random;
            exp_q[i % 16] = d0+d1+d2+d3+d4+d5+d6+d7;
            @(negedge clk);
            //  ★ 迴圈每一圈會經過【兩個】時脈正緣（兩個 negedge 之間各一個），
            //    linear/tree 是 2 級（輸入暫存 + 加總）→ 上一圈的答案
            //    pipe 是 4 級 → 兩圈前的答案
            if (i >= 1 && s_lin  !== exp_q[(i-1) % 16]) err_t = err_t + 1;
            if (i >= 1 && s_tree !== exp_q[(i-1) % 16]) err_t = err_t + 1;
            if (i >= 2 && s_pipe !== exp_q[(i-2) % 16]) err_p = err_p + 1;
        end

        if (err_t == 0) $display("   ★ linear / tree 500 組全部正確");
        else            $display("   [X] linear/tree 有 %0d 處錯", err_t);
        if (err_p == 0) $display("   ★ pipe 500 組全部正確（含 2 拍延遲對齊）");
        else            $display("   [X] pipe 有 %0d 處錯", err_p);

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   ★★★ 功能都一樣。現在跑 03_optimize.bat 看實測差異：");
        $display("");
        $display("     版本           最高時脈     邏輯單元    延遲");
        $display("     ---------------------------------------------------");
        $display("     sum_linear     109.30 MHz     170      2 拍");
        $display("     sum_tree       109.30 MHz     170      2 拍");
        $display("     sum_pipe     ★ 230.04 MHz     141      4 拍");
        $display("");
        $display("   ★★ 兩個【出乎意料】的結果：");
        $display("");
        $display("     1. linear 和 tree 【一模一樣】");
        $display("        我手動把加法鏈改成樹狀，結果完全沒差。");
        $display("        因為 Yosys 自己就會做這件事 —— 這種等級的最佳化");
        $display("        是綜合工具的基本功。");
        $display("");
        $display("        ★ 這正是第 11 週講的：「工具做得到的事，");
        $display("          手動做只會讓程式碼變難讀」。");
        $display("          樹狀寫法唯一的價值是【人比較看得懂結構】。");
        $display("");
        $display("     2. pipe 比較快【而且比較小】（141 vs 170 個邏輯單元）");
        $display("        一般以為切管線一定要多花資源，但這裡反而省了。");
        $display("        因為切開之後每一級的加法器位元數比較窄：");
        $display("          級 1 加 8 位元、級 2 加 9 位元、級 3 加 10 位元，");
        $display("        不像一次全加要一路處理到 11 位元。");
        $display("");
        $display("     ⚠️ 但在 ASIC 上要重算：多了 23 顆正反器，");
        $display("        用第 13 週 tiny_cells.lib 的數字是 23 x 18 = 414");
        $display("        面積單位。FPGA 划算的事，ASIC 不一定划算。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
