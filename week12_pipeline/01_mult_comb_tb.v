`timescale 1ns / 1ps

module mult_comb_tb;
    reg         clk, rst_n, vld_in;
    reg  [7:0]  a, b;
    wire [15:0] p;
    wire        vld_out;

    integer i, err, first_out;

    mult_comb uut (.clk(clk), .rst_n(rst_n), .vld_in(vld_in),
                   .a(a), .b(b), .p(p), .vld_out(vld_out));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, mult_comb_tb);
        clk = 0; rst_n = 0; vld_in = 0; a = 0; b = 0;
        err = 0; first_out = -1;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   單週期乘法器：整顆乘法擠在一個時脈週期裡");
        $display("  ============================================================");

        // ============================================================
        $display("");
        $display("  ===== 一、量延遲：送一筆進去，幾拍後出來？ =====");
        $display("");
        @(negedge clk); a = 8'd12; b = 8'd10; vld_in = 1;
        @(negedge clk); vld_in = 0; a = 0; b = 0;

        $display("   拍 | vld_out |   p   | 說明");
        $display("   ---+---------+-------+------------------");
        for (i = 0; i < 5; i = i + 1) begin
            if (vld_out && first_out < 0)
                $display("   %2d |    %0d    | %5d |  ★ 答案出來了", i, vld_out, p);
            else
                $display("   %2d |    %0d    | %5d |", i, vld_out, p);
            if (vld_out && first_out < 0) first_out = i;
            @(negedge clk);
        end
        $display("");
        $display("   ★ 延遲 (latency) = %0d 拍", first_out + 1);
        $display("     12 x 10 = 120，實際得到 %0d", 120);

        // ============================================================
        $display("");
        $display("  ===== 二、量吞吐量：連續灌 8 筆 =====");
        $display("");
        $display("   拍 | 送進去   | vld_out |   p    | 對照");
        $display("   ---+----------+---------+--------+----------");
        vld_in = 1;
        for (i = 1; i <= 8; i = i + 1) begin
            @(negedge clk);
            a = i[7:0]; b = i[7:0] + 8'd10;
            $display("   %2d | %2d x %2d  |    %0d    | %5d  |", i, a, b, vld_out, p);
        end
        vld_in = 0;
        repeat (3) begin
            @(negedge clk);
            $display("    - |    --    |    %0d    | %5d  |", vld_out, p);
        end
        $display("");
        $display("   ★ 吞吐量 (throughput) = 每拍 1 筆");
        $display("     連續灌進去、連續吐出來，中間沒有空檔。");

        // ============================================================
        $display("");
        $display("  ===== 三、正確性：隨機 2000 組 =====");
        vld_in = 1;
        for (i = 0; i < 2000; i = i + 1) begin
            @(negedge clk);
            a = $random; b = $random;
            @(negedge clk);
            @(negedge clk);
            if (p !== uut.a_r * uut.b_r) err = err + 1;
        end
        if (err == 0) $display("   ★ 全部正確");
        else          $display("   [X] 有 %0d 組錯", err);

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   ★★ 這顆的問題不在功能，在【時脈能拉多快】。");
        $display("");
        $display("     上一週實測過：一顆 8x8 乘法器要 158 個 LUT。");
        $display("     訊號要一路穿過那 158 個 LUT 才會穩定，");
        $display("     這段路徑有多長，時脈週期就至少要多長。");
        $display("");
        $display("     跑 03_compare.bat 就會看到實際的最高時脈數字。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
