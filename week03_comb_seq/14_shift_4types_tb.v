`timescale 1ns / 1ps

module shift_4types_tb;
    localparam W = 8;

    reg          clk, rst_n, sin, load, en;
    reg  [W-1:0] pin;
    wire         siso_out, piso_out;
    wire [W-1:0] sipo_out, pipo_out;

    integer i;
    reg [W-1:0] pattern;
    reg [W-1:0] got;

    shift_4types #(.W(W)) uut (
        .clk(clk), .rst_n(rst_n), .sin(sin), .pin(pin), .load(load), .en(en),
        .siso_out(siso_out), .sipo_out(sipo_out),
        .piso_out(piso_out), .pipo_out(pipo_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, shift_4types_tb);
        clk = 0; rst_n = 0; sin = 0; pin = 0; load = 0; en = 0;
        pattern = 8'b1011_0010;

        #12 rst_n = 1;

        // ============================================================
        $display("");
        $display("  ===== 一、SIPO：串進並出（一位一位收，收滿一次交出）=====");
        $display("");
        $display("   拍  sin |  sipo_out  | 說明");
        $display("   --------+------------+--------------------------");
        en = 1;
        for (i = 0; i < W; i = i + 1) begin
            sin = pattern[W-1-i];      // 由最高位開始餵
            @(negedge clk);
            if (i == W-1)
                $display("   %2d   %0d   |  %b  | ★ 收滿 8 位了", i, sin, sipo_out);
            else
                $display("   %2d   %0d   |  %b  | 還在收", i, sin, sipo_out);
        end
        $display("");
        $display("   餵進去的圖案：%b", pattern);
        if (sipo_out === pattern) $display("   收到的結果  ：%b   ★ 完全一樣", sipo_out);
        else                      $display("   收到的結果  ：%b   [X] 不符",   sipo_out);
        $display("");
        $display("   ★ 這就是 UART 接收端在做的事（第 15 週會用到）");

        // ============================================================
        $display("");
        $display("  ===== 二、PISO：並進串出（一次吃 8 位，一拍吐一位）=====");
        $display("");
        en = 0;
        pin = pattern;
        load = 1; @(negedge clk); load = 0;
        $display("   一次載入 pin = %b", pattern);
        $display("");
        $display("   拍 | piso_out | 累積收到");
        $display("   ---+----------+----------");
        en = 1;
        got = 0;
        for (i = 0; i < W; i = i + 1) begin
            got = {got[W-2:0], piso_out};
            $display("   %2d |    %0d     | %b", i, piso_out, got);
            @(negedge clk);
        end
        $display("");
        $display("   載入的  ：%b", pattern);
        if (got === pattern) $display("   吐出來的：%b   ★ 完全一樣", got);
        else                 $display("   吐出來的：%b   [X] 不符",   got);
        $display("");
        $display("   ★ 這就是 UART 發送端在做的事");

        // ============================================================
        $display("");
        $display("  ===== 三、SISO：串進串出（純延遲線）=====");
        $display("");
        rst_n = 0; @(negedge clk); rst_n = 1;
        en = 1;
        $display("   餵一個單發脈衝進去，看它幾拍之後出來：");
        $display("");
        $display("   拍 | sin | siso_out");
        $display("   ---+-----+---------");
        for (i = 0; i < 11; i = i + 1) begin
            sin = (i == 0) ? 1'b1 : 1'b0;     // 只在第 0 拍給一個 1
            @(negedge clk);
            if (siso_out === 1'b1)
                $display("   %2d |  %0d  |    %0d   <== ★ 出來了", i, sin, siso_out);
            else
                $display("   %2d |  %0d  |    %0d", i, sin, siso_out);
        end
        $display("");
        $display("   ★ 第 0 拍進去、第 %0d 拍出來 —— SISO 就是一條【延遲 %0d 拍】的線",
                 W-1, W);

        // ============================================================
        $display("");
        $display("  ===== 四、PIPO：並進並出 =====");
        $display("");
        en = 0;
        pin = 8'hC3; load = 1; @(negedge clk); load = 0;
        $display("   載入 8'hC3 → pipo_out = %b（%h）", pipo_out, pipo_out);
        pin = 8'h3C; @(negedge clk);
        $display("   load=0 時改 pin，pipo_out 還是 %h（沒反應）", pipo_out);
        load = 1; @(negedge clk); load = 0;
        $display("   load=1 再載一次 → pipo_out = %h", pipo_out);
        $display("");
        $display("   ★ PIPO 根本沒有移位，就是一組普通的暫存器（課本 9.1.5）");

        // ============================================================
        $display("");
        $display("  ------------------------------------------------------------");
        $display("   四種一次記起來：");
        $display("     SISO  串進串出  → 延遲線");
        $display("     SIPO  串進並出  → 收資料（UART RX）");
        $display("     PISO  並進串出  → 送資料（UART TX）");
        $display("     PIPO  並進並出  → 普通暫存器");
        $display("");
        $display("   ★ SISO 和 SIPO 的【電路完全一樣】，差別只在「拉幾條線出來」");
        $display("");
        #20 $finish;
    end
endmodule
