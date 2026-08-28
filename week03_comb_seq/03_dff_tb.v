`timescale 1ns / 1ps

module dff_tb;
    reg clk = 0, rst, d;
    wire q_sync, q_async, q_en;

    dff uut (.clk(clk), .rst(rst), .d(d), .q_sync(q_sync), .q_async(q_async), .q_en(q_en));

    always #5 clk = ~clk;      // 週期 10ns

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, dff_tb);

        $monitor("  t=%3d  clk=%b rst=%b d=%b | q_sync=%b q_async=%b",
                 $time, clk, rst, d, q_sync, q_async);

        rst = 1; d = 0;
        #23 rst = 0;           // 在「不是時脈邊緣」的時間點放開
        d = 1;
        #20 d = 0;
        #20 d = 1;

        // ★ 關鍵實驗：在兩個時脈邊緣「中間」戳一下 rst
        #13 rst = 1;           // t=76 左右，clk 正好是低的
        #4  rst = 0;           // 只拉高 4ns 就放掉，沒碰到任何上升緣

        #30;
        $display("");
        $display("  ★★ 看波形最重要的一段：t=76 附近那個很短的 rst 脈衝");
        $display("     q_async 立刻被清成 0（它不等時脈）");
        $display("     q_sync  完全沒反應（脈衝結束時還沒遇到上升緣）");
        $display("");
        $display("     這就是同步/非同步 reset 的真正差別。");
        $display("");
        $finish;
    end
endmodule
