// ============================================================
//  W5-4：用亂數測試抓 bug
//  重點：$random 撒亂數 + 參考模型比對，能抓出人眼看不出的錯
// ============================================================
`timescale 1ns / 1ps

module comparator_tb;

    reg  [7:0] a, b;
    wire       gt, eq, lt;
    integer    i, pass = 0, fail = 0, first_fail = -1;
    reg        seed_dummy;
    integer    seed = 1234;      // ★ 固定種子 → 每次跑結果一樣，方便重現

    comparator uut (.a(a), .b(b), .gt(gt), .eq(eq), .lt(lt));

    task check;
        begin
            #2;
            if (gt === (a > b) && eq === (a == b) && lt === (a < b)) begin
                pass = pass + 1;
            end else begin
                fail = fail + 1;
                if (first_fail < 0) first_fail = i;
                if (fail <= 5)
                    $display("   [X] 第%0d次  a=%0d b=%0d | 得到 gt=%b eq=%b lt=%b，應該是 %b %b %b",
                             i, a, b, gt, eq, lt, (a > b), (a == b), (a < b));
            end
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, comparator_tb);

        $display("");
        $display("  ===== 用亂數測試 2000 組 =====");
        $display("  （這個 DUT 故意藏了一個 bug，看能不能抓到）");
        $display("");

        for (i = 0; i < 2000; i = i + 1) begin
            a = $random(seed);
            b = $random(seed);
            // 刻意提高「相等」的機率，模擬「邊界值測試」的想法
            if (i % 7 == 0) b = a;
            check;
        end

        $display("");
        $display("  ==========================================");
        $display("     通過 %0d 組，失敗 %0d 組", pass, fail);
        if (fail == 0)
            $display("     >>> 全部通過（測試強度可能不夠）");
        else
            $display("     >>> 抓到 bug！第一次失敗在第 %0d 次", first_fail);
        $display("  ==========================================");
        $display("");
        $display("  ★ bug 在哪：04_random_test.v 裡 lt 寫成 (a <= b)，應該是 (a < b)");
        $display("    只有 a == b 的時候才會錯 —— 這種「邊界 bug」用眼睛很難看出來");
        $display("");
        $display("  ★ 兩個測試技巧：");
        $display("    1. 固定亂數種子 → 失敗可以重現，不會這次錯下次對");
        $display("    2. 刻意加入邊界值（這裡是強迫 a==b）→ 大幅提高抓 bug 機率");
        $display("");
        $display("  ★ 練習：把 (a <= b) 改成 (a < b) 再跑一次，應該全過");
        $display("");

        $finish;
    end
endmodule
