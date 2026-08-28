`timescale 1ns / 1ps

module comb_blocking_tb;

    reg  a, b, c;
    wire y_ok, y_bad;
    integer glitches = 0;

    comb_blocking uut (.a(a), .b(b), .c(c), .y_ok(y_ok), .y_bad(y_bad));

    // 抓 y_bad 跳動的次數（正確的電路每次輸入變化最多跳一次）
    always @(y_bad) if ($time > 0) glitches = glitches + 1;

    task try(input va, input vb, input vc);
        begin
            a = va; b = vb; c = vc;
            #0;                          // 完全不等，立刻看
            $display("   a=%b b=%b c=%b |  剛設定完 : y_ok=%b   y_bad=%b",
                     a, b, c, y_ok, y_bad);
            #5;                          // 等訊號穩定
            $display("                 |  等 5ns 後: y_ok=%b   y_bad=%b     正確答案=%b",
                     y_ok, y_bad, (va & vb) | vc);
            $display("");
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, comb_blocking_tb);

        $display("");
        $display("   電路：y = (a & b) | c      中間值 tmp = a & b");
        $display("");
        $display("   y_ok  = always @(*) 裡用 =   （正確）");
        $display("   y_bad = always @(*) 裡用 <=  （錯誤）");
        $display("");
        $display("  --------------------------------------------------------");

        try(0, 0, 0);
        try(1, 1, 0);
        try(0, 0, 0);
        try(1, 1, 1);
        try(0, 1, 0);
        try(1, 0, 1);

        $display("  --------------------------------------------------------");
        $display("");
        $display("  ★★ 看「剛設定完」那一欄：");
        $display("     y_ok  一設定就是正確答案");
        $display("     y_bad 先給一個錯的值，等 5ns 之後才追上");
        $display("");
        $display("     y_bad 總共跳動 %0d 次（正確的電路不該跳這麼多）", glitches);
        $display("");
        $display("  ★ 為什麼？");
        $display("     <= 是「先把右邊全部讀好，再一起寫左邊」。");
        $display("     所以第二句讀 tmp2 的時候，第一句還沒寫進去，");
        $display("     讀到的是「上一次」的 tmp2 —— 慢了一步。");
        $display("");
        $display("  ★ 這叫毛刺（glitch）。第 7 週會講它什麼時候會害你出事。");
        $display("");
        $display("  ★★ 完整規則：");
        $display("     assign                 -> 只能用 =（連續指定）");
        $display("     always @(*)            -> 用 =    後面要看到前面的結果");
        $display("     initial                -> 用 =    像腳本，依序執行");
        $display("     always @(posedge clk)  -> 用 <=   正反器同時抓舊值");
        $display("");
        $display("     時脈區塊用錯 =  -> 看範例 04（正反器會塌掉）");
        $display("     組合區塊用錯 <= -> 就是這個範例（產生毛刺）");
        $display("");

        #10 $finish;
    end

endmodule
