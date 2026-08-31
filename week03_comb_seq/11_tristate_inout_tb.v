`timescale 1ns / 1ps

module tristate_inout_tb;
    reg        drive_a, drive_b, tb_oe;
    reg  [7:0] tb_din;
    wire [7:0] bus, a_seen, b_seen, tb_dout;

    tristate_inout uut (
        .drive_a(drive_a), .drive_b(drive_b),
        .bus(bus), .a_seen(a_seen), .b_seen(b_seen),
        .tb_din(tb_din), .tb_oe(tb_oe), .tb_dout(tb_dout)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tristate_inout_tb);

        $display("");
        $display("  ===== 一、單純的三態閘 =====");
        $display("");
        $display("   oe  din      | dout");
        $display("   --------------+----------");
        tb_din = 8'hC3; tb_oe = 1; #10;
        $display("    %0d  %b | %b   ← 正常送出", tb_oe, tb_din, tb_dout);
        tb_oe = 0; #10;
        $display("    %0d  %b | %b   ← ★ 全部變 z，等於把腳拔掉", tb_oe, tb_din, tb_dout);

        $display("");
        $display("  ===== 二、兩個裝置共用一條匯流排 =====");
        $display("");
        $display("   dev_a 想送 8'hAA = 10101010");
        $display("   dev_b 想送 8'h55 = 01010101");
        $display("");
        $display("   drive_a drive_b |    bus     | 狀況");
        $display("   ----------------+------------+---------------------------");

        drive_a = 0; drive_b = 0; #10;
        $display("      %0d       %0d     |  %b  | 都不說話 → 整條線浮空 (z)",
                 drive_a, drive_b, bus);

        drive_a = 1; drive_b = 0; #10;
        $display("      %0d       %0d     |  %b  | 只有 A 說話 → 線上是 AA",
                 drive_a, drive_b, bus);

        drive_a = 0; drive_b = 1; #10;
        $display("      %0d       %0d     |  %b  | 只有 B 說話 → 線上是 55",
                 drive_a, drive_b, bus);

        drive_a = 1; drive_b = 1; #10;
        $display("      %0d       %0d     |  %b  | ★★ 兩個同時說話 → 全部變 x",
                 drive_a, drive_b, bus);

        $display("");
        $display("   ★★ 最後那一行就是【匯流排衝突】(bus contention)：");
        $display("      A 想拉 1、B 想拉 0，模擬器不知道誰贏，只好給 x。");
        $display("      真實電路裡這是【一顆閘在灌電流給另一顆】—— 會發熱、會燒。");
        $display("      所以用 inout 一定要有仲裁：同一時間只能有一個 drive=1。");

        $display("");
        $display("  ===== 三、聽的那一端 =====");
        drive_a = 1; drive_b = 0; #10;
        $display("   A 在說話時：a_seen=%b  b_seen=%b", a_seen, b_seen);
        $display("   ★ 兩邊看到的是同一條線，所以【說話的人也聽得到自己】");

        $display("");
        $display("   三個重點：");
        $display("     1. z 不是 0 也不是 1，是「我放手」");
        $display("     2. inout 的標準寫法就一行：assign bus = drive ? data : 8'bz;");
        $display("     3. ★ 同時兩個人 drive → x → 真實電路會燒");
        $display("");
        #20 $finish;
    end
endmodule
