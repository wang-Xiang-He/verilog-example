`timescale 1ns / 100ps

module glitch_demo_tb;
    reg  a;
    wire y_ideal, y_real;
    integer glitch_count = 0;

    glitch_demo uut (.a(a), .y_ideal(y_ideal), .y_real(y_real));

    // 抓毛刺：y_real 只要掉到 0 就記一次
    always @(negedge y_real) begin
        glitch_count = glitch_count + 1;
        $display("   ★ t=%3t  抓到毛刺！y_real 掉到 0 了", $time);
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, glitch_demo_tb);

        $display("");
        $display("   電路是 y = a | ~a  —— 數學上永遠等於 1");
        $display("");

        a = 0;
        #20 a = 1;
        #20 a = 0;
        #20 a = 1;
        #20 a = 0;
        #20;

        $display("");
        $display("   理想版 y_ideal 全程 = %b（一直是 1，沒問題）", y_ideal);
        $display("   真實版 y_real  抓到 %0d 次毛刺", glitch_count);
        $display("");
        $display("  ★★ 為什麼會這樣？");
        $display("     a 變化時，~a 那條路要多穿過一顆反相器（慢 2ns）。");
        $display("     那 2ns 之內 a=0 而 ~a 還是 0 → y = 0|0 = 0");
        $display("     這叫「毛刺 glitch」，是組合邏輯的暫態錯誤。");
        $display("");
        $display("  ★ 為什麼平常沒事？");
        $display("     因為輸出都接到正反器，而正反器只在時脈邊緣取樣。");
        $display("     只要毛刺在下一個邊緣之前消失，就沒影響。");
        $display("");
        $display("  ★ 什麼時候會出事？");
        $display("     1. 用組合邏輯直接當時脈（絕對禁止！）");
        $display("     2. 用組合邏輯直接當非同步 reset");
        $display("     3. 訊號直接接出晶片外");
        $display("");
        $display("  ★ 這就是「同步設計」的核心原則：");
        $display("     所有東西都用同一個時脈的邊緣取樣，毛刺自然被過濾掉。");
        $display("");
        $finish;
    end
endmodule
