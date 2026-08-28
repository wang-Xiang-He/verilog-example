`timescale 1ns / 1ps

module latch_trap_tb;
    reg        en;
    reg  [3:0] d;
    wire [3:0] bad, good;

    latch_trap uut (.en(en), .d(d), .bad(bad), .good(good));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, latch_trap_tb);

        $display("");
        $display("   時間  en   d   |  bad   good      說明");
        $display("  -------------------------------------------------");

        en = 1; d = 4'hA; #20;
        $display("   %0t   1   A   |   %h     %h        兩個都跟著 d", $time/1000, bad, good);

        en = 0; d = 4'hA; #20;
        $display("   %0t   0   A   |   %h     %h        ★ bad 卡住不放！", $time/1000, bad, good);

        en = 0; d = 4'h5; #20;
        $display("   %0t   0   5   |   %h     %h        ★ d 變了 bad 還是舊值", $time/1000, bad, good);

        en = 1; d = 4'h5; #20;
        $display("   %0t   1   5   |   %h     %h        en 一開 bad 才更新", $time/1000, bad, good);

        en = 0; d = 4'hF; #20;
        $display("   %0t   0   F   |   %h     %h        ★ 又卡住了", $time/1000, bad, good);

        $display("");
        $display("  ★★ bad 記住了上一次的值 —— 它變成了一個「閂鎖器 latch」");
        $display("     你以為在寫組合邏輯，實際做出了會記憶的東西。");
        $display("     latch 在 FPGA 裡會造成時序無法分析，是設計大忌。");
        $display("");
        $display("  修法：組合邏輯的 always 裡，每條路徑都要給值。");
        $display("        最簡單 = 在 always 最上面先給預設值。");
        $display("");

        #20 $finish;
    end
endmodule
