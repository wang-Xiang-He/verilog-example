`timescale 1ns / 1ps

module jk_t_ff_tb;
    reg clk, rst_n, j, k, t, d;
    wire q_jk, q_t, q_d, q_t_from_jk, q_jk_from_d;

    integer i, err_t, err_jk;

    jk_t_ff uut (.clk(clk), .rst_n(rst_n), .j(j), .k(k), .t(t), .d(d),
                 .q_jk(q_jk), .q_t(q_t), .q_d(q_d),
                 .q_t_from_jk(q_t_from_jk), .q_jk_from_d(q_jk_from_d));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, jk_t_ff_tb);
        clk = 0; rst_n = 0; j = 0; k = 0; t = 0; d = 0;
        err_t = 0; err_jk = 0;

        #12 rst_n = 1;

        $display("");
        $display("  ===== 一、JK 正反器的四種輸入 =====");
        $display("");
        $display("   J K | 動作      | 之前  之後");
        $display("   ----+-----------+------------");

        // 先把 q_jk 設成 1
        j = 1; k = 0; @(negedge clk);
        $display("   1 0 | 設 1      |   ?     %0d", q_jk);

        j = 0; k = 0; @(negedge clk);
        $display("   0 0 | 保持      |   1     %0d", q_jk);

        j = 0; k = 1; @(negedge clk);
        $display("   0 1 | 清 0      |   1     %0d", q_jk);

        j = 0; k = 0; @(negedge clk);
        $display("   0 0 | 保持      |   0     %0d", q_jk);

        $display("");
        $display("   ---- ★ J=K=1 連續四拍，看它一直翻 ----");
        j = 1; k = 1;
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge clk);
            $display("   1 1 | 反相      |         %0d", q_jk);
        end

        $display("");
        $display("  ===== 二、T 正反器：T=1 就翻 =====");
        $display("");
        $display("   拍  T | q_t   說明");
        $display("   ------+---------------------------");
        j = 0; k = 0;
        for (i = 0; i < 8; i = i + 1) begin
            t = (i < 4) ? 1'b1 : ((i % 2 == 0) ? 1'b1 : 1'b0);
            @(negedge clk);
            //  ★ 注意：不要用 %s 去印「三元運算子選出來的中文字串」，
            //    兩個字串長度不同時短的會被補 0，印出來會變亂碼。
            //    要分開寫成 if / else。
            if (i < 4)
                $display("   %2d  %0d |  %0d    T 一直是 1 → 每拍都翻（就是除以 2）", i, t, q_t);
            else
                $display("   %2d  %0d |  %0d    T 忽 0 忽 1", i, t, q_t);
        end

        $display("");
        $display("  ===== 三、★ 兜出來的和原生的應該一模一樣 =====");
        $display("");
        $display("   隨機 500 拍，同時比對兩組：");
        $display("     T  vs  用 JK 兜的 T");
        $display("     JK vs  用 D  兜的 JK");
        $display("");

        // 先讓兩組的起點一致
        rst_n = 0; @(negedge clk); rst_n = 1;

        for (i = 0; i < 500; i = i + 1) begin
            j = $random;
            k = $random;
            t = $random;
            d = $random;
            @(negedge clk);
            if (q_t  !== q_t_from_jk) err_t  = err_t  + 1;
            if (q_jk !== q_jk_from_d) err_jk = err_jk + 1;
        end

        if (err_t == 0) $display("   ★ T 和「JK 兜的 T」完全一致（0 個不符）");
        else            $display("   [X] T 有 %0d 拍不一致", err_t);

        if (err_jk == 0) $display("   ★ JK 和「D 兜的 JK」完全一致（0 個不符）");
        else             $display("   [X] JK 有 %0d 拍不一致", err_jk);

        $display("");
        $display("   ------------------------------------------------------------");
        $display("   考試會考的三個式子：");
        $display("     D  正反器： Q(next) = D");
        $display("     T  正反器： Q(next) = T XOR Q");
        $display("     JK 正反器： Q(next) = J·Q' + K'·Q      ★ 特徵方程式");
        $display("");
        $display("   實務上的真相：");
        $display("     FPGA 裡面【只有 D 正反器】。你寫 JK 或 T，");
        $display("     綜合工具都是拿 D 正反器 + 幾顆閘兜出來給你的。");
        $display("     所以平常寫 D 就好，JK/T 是拿來應付考試和讀舊電路圖的。");
        $display("");
        #20 $finish;
    end
endmodule
