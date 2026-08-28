`timescale 1ns / 1ps

module clk_gen_tb;
    reg  rst = 0;
    wire clk_10ns, clk_40ns;
    integer edges_100m = 0, edges_25m = 0;

    clk_gen uut (.rst(rst), .clk_10ns(clk_10ns), .clk_40ns(clk_40ns));

    always @(posedge clk_10ns) edges_100m = edges_100m + 1;
    always @(posedge clk_40ns) edges_25m  = edges_25m  + 1;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk_gen_tb);

        $display("");
        $display("  `timescale 1ns / 1ps");
        $display("             ^^^   ^^^");
        $display("             單位   精度");
        $display("");
        $display("   單位：#1 代表 1ns");
        $display("   精度：模擬器能分辨到 1ps（#0.001 才有意義）");
        $display("");
        $display("   $time 回傳的是「單位」的倍數，$realtime 可以有小數");
        $display("");

        #1;    $display("   等 #1    後 → $time = %0t ns", $time);
        #9;    $display("   再等 #9  後 → $time = %0t ns", $time);
        #990;  $display("   再等 #990後 → $time = %0t ns  (= 1 微秒)", $time);

        $display("");
        $display("   1000ns 之內：");
        $display("     100MHz 時脈（週期 10ns）跑了 %0d 個上升緣", edges_100m);
        $display("     25MHz  時脈（週期 40ns）跑了 %0d 個上升緣", edges_25m);
        $display("");
        $display("  ★ 把檔案最上面的 `timescale 改成 1us / 1ns 再跑一次，");
        $display("    程式碼一個字都不用改，但整個時間軸會慢 1000 倍。");
        $display("    這就是為什麼每個檔案最上面都要寫 `timescale。");
        $display("");
        $display("  ★ 沒寫 `timescale 會怎樣？");
        $display("    → 預設變成 1 秒（你 week00 的波形顯示「115 sec」就是這樣來的）");
        $display("");

        $finish;
    end
endmodule
