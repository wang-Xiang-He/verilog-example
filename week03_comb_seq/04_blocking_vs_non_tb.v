`timescale 1ns / 1ps

module blocking_vs_non_tb;
    reg clk = 0, rst, d;
    wire q1_nb, q2_nb, q3_nb, q1_b, q2_b, q3_b;
    integer n = 0;

    blocking_vs_non uut (
        .clk(clk), .rst(rst), .d(d),
        .q1_nb(q1_nb), .q2_nb(q2_nb), .q3_nb(q3_nb),
        .q1_b(q1_b),   .q2_b(q2_b),   .q3_b(q3_b)
    );

    always #5 clk = ~clk;

    // 每次呼叫都等一個上升緣，再等 1ns 讓所有更新塵埃落定才印
    task tick;
        begin
            @(posedge clk);
            #1;
            n = n + 1;
            $display("    第 %0d 拍    d=%b   |    %b  %b  %b    |    %b  %b  %b",
                     n, d, q1_nb, q2_nb, q3_nb, q1_b, q2_b, q3_b);
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, blocking_vs_non_tb);

        rst = 1; d = 0;
        @(posedge clk); @(posedge clk);
        #1 rst = 0;

        $display("");
        $display("  只送「一拍」的 1 進去，看它怎麼在三顆正反器裡傳遞");
        $display("");
        $display("                        非阻塞 <=       阻塞 =");
        $display("                       q1 q2 q3       q1 q2 q3");
        $display("  ------------------------------------------------");

        d = 1;  tick;      // 第 1 拍：d=1 被抓進去
        d = 0;  tick;      // 之後 d 都是 0
                tick;
                tick;
                tick;

        $display("");
        $display("  ★★ 差別非常明顯：");
        $display("");
        $display("     非阻塞 <= ：1 依序走過 q1 → q2 → q3，走了 3 拍");
        $display("                 → 綜合出來真的是 3 顆正反器串起來");
        $display("");
        $display("     阻塞  =   ：第 1 拍 q1 q2 q3 同時變成 1，第 2 拍就全沒了");
        $display("                 → 三行程式碼塌成 1 顆正反器！");
        $display("");
        $display("     為什麼？");
        $display("       <=  先把右邊全部讀好，再一起寫左邊 → q2 讀到 q1 的「舊值」");
        $display("       =   一行做完才做下一行         → q2 讀到 q1 的「新值」");
        $display("");
        $display("  口訣：always @(posedge clk) 裡 → 一律用 <=");
        $display("        always @(*)           裡 → 一律用 =");
        $display("");

        #20 $finish;
    end
endmodule
