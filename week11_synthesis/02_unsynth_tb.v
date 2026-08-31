`timescale 1ns / 1ps

module unsynth_tb;
    reg        clk, rst_n, en;
    reg  [3:0] d;

    wire [3:0] q_good;
    wire [3:0] q_bad, q_delay;
    wire       is_unknown;
`ifdef SIM_ONLY
    wire real  measured;
`endif

    wire [3:0] latched, wrong_ff, q1, q2, q3;

    integer i;

    good_design  u_good (.clk(clk), .rst_n(rst_n), .d(d), .q(q_good));

    bad_design   u_bad  (.clk(clk), .rst_n(rst_n), .d(d),
                         .q(q_bad), .q_delay(q_delay),
                         .is_unknown(is_unknown)
`ifdef SIM_ONLY
                         , .measured(measured)
`endif
                         );

    subtle_trap  u_trap (.clk(clk), .en(en), .d(d),
                         .latched(latched), .wrong_ff(wrong_ff),
                         .q1(q1), .q2(q2), .q3(q3));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, unsynth_tb);
        clk = 0; rst_n = 0; en = 1; d = 4'd0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   不能合成的語法：模擬全部跑得動，但做不出電路");
        $display("  ============================================================");

        // ============================================================
        $display("");
        $display("  ===== 一、initial 的值真的生效了（在模擬裡）=====");
        $display("");
        $display("   bad_design 的 initial 把 q 設成 7");
        $display("   模擬一開始 q_bad = %0d", q_bad);
        $display("");
        $display("   ⚠️ 但真實晶片開機時，正反器的值是【不確定】的。");
        $display("      要有確定的起始值，只能靠 reset。");
        $display("      good_design 用的就是 reset，那才是對的寫法。");

        // ============================================================
        $display("");
        $display("  ===== 二、# 延遲在模擬裡有效，綜合時會被丟掉 =====");
        $display("");
        $display("   拍 |  d  | q_good | q_delay | 說明");
        $display("   ---+-----+--------+---------+------------------------");
        for (i = 1; i <= 5; i = i + 1) begin
            @(negedge clk); d = i[3:0];
            @(negedge clk);
            $display("   %2d |  %0d  |   %0d    |    %0d    | 兩個都跟上了（模擬）",
                     i, d, q_good, q_delay);
        end
        $display("");
        $display("   ⚠️ 綜合之後 #3 消失，q_delay 會變成和 q_good 完全一樣的電路。");
        $display("      也就是說：【模擬對不代表電路對】。");

        // ============================================================
        $display("");
        $display("  ===== 三、=== 可以比 x，但硬體上沒有 x 這種電位 =====");
        $display("");
        d = 4'bxxxx; #1;
        $display("   d = xxxx 時  is_unknown = %0d  ← 模擬裡分得出來", is_unknown);
        d = 4'b1010; #1;
        $display("   d = 1010 時  is_unknown = %0d", is_unknown);
        $display("");
        $display("   ⚠️ 真實電路每條線【不是高電位就是低電位】，");
        $display("      沒有第三種狀態可以拿來比。");
        $display("      x 是【模擬器用來表示「我不知道」】的記號，不是電位。");
        $display("      所以 === 和 !== 永遠不能合成。");

        // ============================================================
        $display("");
        $display("  ===== 四、real 型別 =====");
        $display("");
        @(negedge clk);
`ifdef SIM_ONLY
        $display("   measured = %0.2f  ← 模擬裡是浮點數", measured);
`endif
        $display("");
        $display("   ⚠️ 硬體只有位元，沒有浮點數單元（除非你自己做一顆）。");
        $display("      要小數就用第 2 週 08_fixed_point 的定點數。");

        // ============================================================
        $display("");
        $display("  ===== 五、★ 更危險的：語法合法，但電路不是你想的 =====");
        $display("");
        $display("   ---- 陷阱 1：漏 else → latch ----");
        en = 1; d = 4'hA; #1;
        $display("     en=1 d=A → latched = %h", latched);
        en = 0; d = 4'h5; #1;
        $display("     en=0 d=5 → latched = %h  ★ 卡住不動 = latch", latched);

        $display("");
        $display("   ---- 陷阱 2：時脈區塊用 = → 三顆正反器塌成一顆 ----");
        en = 1;
        @(negedge clk); d = 4'd1;
        @(negedge clk);
        $display("     d=1 一拍後 q1=%0d q2=%0d q3=%0d  ★ 全部同時變", q1, q2, q3);
        @(negedge clk); d = 4'd0;
        @(negedge clk);
        $display("     d=0 一拍後 q1=%0d q2=%0d q3=%0d  ★ 全部同時歸零", q1, q2, q3);
        $display("");
        $display("     正確的移位暫存器應該是 1 → 0 → 0，一格一格走。");
        $display("     用了 = 就塌成一顆，但【編譯完全不會報錯】。");

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   總結：三種嚴重程度");
        $display("");
        $display("     等級 1  綜合工具【報錯】   → 最好的情況，馬上就知道");
        $display("             例：兩個 always 驅動同一個變數");
        $display("");
        $display("     等級 2  綜合工具【警告】   → 會被忽略，要養成看 warning 的習慣");
        $display("             例：漏 else 生 latch");
        $display("");
        $display("     等級 3  綜合工具【默默照做】← ★★ 最可怕");
        $display("             例：#延遲被丟掉、時脈區塊用 = 塌成一顆");
        $display("             模擬對、綜合過、上板子就是不動，而且查不出原因");
        $display("");
        $display("   ★ 所以：模擬通過只是【第一關】。");
        $display("     每次改完設計都要跑一次綜合，把 warning 看完。");
        $display("");
        $display("   下一步：yosys -s 02_unsynth.ys  看工具實際怎麼抱怨");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
