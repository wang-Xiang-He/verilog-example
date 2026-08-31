`timescale 1ns / 1ps

module accum_mac_tb;
    reg         clk, rst_n, en;
    reg  [7:0]  a, b;
    wire [15:0] acc, mac, acc_next;
    wire        acc_ovf;

    integer i;
    integer exp_acc, exp_mac, err;

    accum_mac uut (.clk(clk), .rst_n(rst_n), .en(en), .a(a), .b(b),
                   .acc(acc), .mac(mac), .acc_next(acc_next), .acc_ovf(acc_ovf));

    always #5 clk = ~clk;      // 10ns 週期

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, accum_mac_tb);
        clk = 0; rst_n = 0; en = 0; a = 0; b = 0;
        exp_acc = 0; exp_mac = 0; err = 0;

        $display("");
        $display("  ===== 一、累加器：每拍把 a 加進去 =====");
        $display("");
        $display("   拍  en   a    b  | acc_next |  acc    mac  | 溢位");
        $display("   ----+---+----+----+----------+--------------+-----");

        #12 rst_n = 1;         // 放開 reset
        en = 1;

        for (i = 1; i <= 10; i = i + 1) begin
            a = i[7:0] * 8'd7;
            b = i[7:0] * 8'd3;
            @(negedge clk);    // 在時脈低準位時觀察，值最穩定
            $display("   %2d   %0d  %3d  %3d |  %5d   | %5d  %5d |  %0d",
                     i, en, a, b, acc_next, acc, mac, acc_ovf);
            exp_acc = exp_acc + a;
            exp_mac = exp_mac + a * b;
        end

        $display("");
        if (acc == exp_acc) $display("   累加器結果 acc = %0d，人工算 = %0d   OK",  acc, exp_acc);
        else                $display("   累加器結果 acc = %0d，人工算 = %0d   [X]", acc, exp_acc);
        if (mac == exp_mac) $display("   乘加器結果 mac = %0d，人工算 = %0d   OK",  mac, exp_mac);
        else                $display("   乘加器結果 mac = %0d，人工算 = %0d   [X]", mac, exp_mac);
        if (acc !== exp_acc[15:0]) err = err + 1;
        if (mac !== exp_mac[15:0]) err = err + 1;

        $display("");
        $display("  ===== 二、en 關掉的時候應該完全不動 =====");
        en = 0;
        a = 8'd200; b = 8'd200;
        @(negedge clk);
        $display("   en=0, a=200 → acc 還是 %0d（沒被加進去）", acc);
        @(negedge clk);
        $display("   再過一拍     → acc 還是 %0d", acc);
        if (acc !== exp_acc[15:0]) err = err + 1;

        $display("");
        $display("  ===== 三、reset 立刻清零（非同步）=====");
        en = 1;
        #2 rst_n = 0;          // 故意不對齊時脈邊緣
        #1;
        $display("   rst_n 拉低後【不等時脈】acc 就變 %0d", acc);
        if (acc !== 16'd0) err = err + 1;
        #5 rst_n = 1;

        $display("");
        $display("  ------------------------------------------------------------");
        if (err == 0) $display("   ★ 全部檢查通過");
        else          $display("   [X] 有 %0d 項不符", err);
        $display("");
        $display("   要看的重點：");
        $display("     1. acc_next 是【這一拍就算好】的，acc 要【下一拍】才變");
        $display("        → 波形上這兩條永遠差一拍，這就是正反器在做的事");
        $display("     2. 累加器 = 加法器 + 正反器 + 一條繞回自己的線");
        $display("     3. 循序區塊漏 else 是【保持原值】，是正確寫法；");
        $display("        組合區塊漏 else 才會生 latch。兩者不要搞混。");
        $display("");
        #20 $finish;
    end
endmodule
