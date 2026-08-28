`timescale 1ns / 1ps

module dut_tb;
    reg clk = 0;
    reg  [3:0] d;
    wire [3:0] q;

    dut uut (.clk(clk), .d(d), .q(q));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, dut_tb);

        $display("");
        $display("  ===== 四種印法的差別 =====");
        $display("");
        $display("  $display : 呼叫的當下立刻印（可能印到「還沒更新」的值）");
        $display("  $strobe  : 等這個時間點所有事情都做完才印（值一定是最終的）");
        $display("  $monitor : 只要參數裡任何一個變了就自動印（全程只需設定一次）");
        $display("  $write   : 跟 $display 一樣但「不換行」");
        $display("");

        // $monitor 只能有一個作用中，設定一次就好
        $monitor("      [monitor] t=%3t  d=%h  q=%h", $time, d, q);

        d = 4'h1;
        @(posedge clk);
        $display("      [display] t=%3t  d=%h  q=%h  ★ q 還是舊值！", $time, d, q);
        $strobe ("      [strobe ] t=%3t  d=%h  q=%h  ★ q 已更新", $time, d, q);

        #1 d = 4'h2;      // 讓 $strobe 先印完再改 d
        @(posedge clk);
        $display("      [display] t=%3t  d=%h  q=%h", $time, d, q);
        $strobe ("      [strobe ] t=%3t  d=%h  q=%h", $time, d, q);

        #1 d = 4'h3;
        @(posedge clk);
        #1;   // 等 1ns 再印，$display 也看得到新值了
        $display("      [display] t=%3t  d=%h  q=%h  (延遲 1ns 才印)", $time, d, q);

        @(posedge clk);
        $display("");
        $write("      $write 不換行：");
        $write("A");
        $write("B");
        $write("C");
        $write("\n");
        $display("");
        $display("  ★★ 重要結論：");
        $display("     在 @(posedge clk) 之後馬上 $display，看到的是「舊值」，");
        $display("     因為非阻塞 <= 的更新還沒生效。");
        $display("     想看最終值 → 用 $strobe，或加 #1 延遲。");
        $display("     這是初學除錯時最容易被騙的地方。");
        $display("");
        $finish;
    end
endmodule
