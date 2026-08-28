// ============================================================
//  W0-2 的測試平台 —— 印出每個語法的實際結果
// ============================================================
`timescale 1ns / 1ps

module syntax_demo_tb;

    reg  [7:0] a, b;
    wire [15:0] joined, repeated;
    wire [7:0]  reversed, mixed, reversed_f;
    wire [7:0]  const_bin, const_hex, const_dec;
    wire [3:0]  ones;

    integer i;

    syntax_demo uut (
        .a(a), .b(b),
        .joined(joined), .repeated(repeated),
        .reversed(reversed), .mixed(mixed),
        .ones(ones), .reversed_f(reversed_f),
        .const_bin(const_bin), .const_hex(const_hex), .const_dec(const_dec)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, syntax_demo_tb);

        a = 8'b1100_0001;
        b = 8'b0000_1111;
        #10;

        $display("");
        $display("  ============================================================");
        $display("   一、常數的三種寫法（都是同一個值 165）");
        $display("  ============================================================");
        $display("    8'b1010_0101  ->  %b  = %0d", const_bin, const_bin);
        $display("    8'hA5         ->  %b  = %0d", const_hex, const_hex);
        $display("    8'd165        ->  %b  = %0d", const_dec, const_dec);
        $display("");
        $display("    格式：  <幾位元> ' <進位> <值>");
        $display("              8      '   h    A5");
        $display("    底線 _ 只是給人看的分隔，電腦會忽略");

        $display("");
        $display("  ============================================================");
        $display("   二、大括號 {} —— 把線黏在一起（不是 Python 的 dict!）");
        $display("  ============================================================");
        $display("    a = %b", a);
        $display("    b = %b", b);
        $display("");
        $display("    {a, b}                 = %b   (8+8=16 位元)", joined);
        $display("    {2{a}}                 = %b   (複製兩次)", repeated);
        $display("    {a[0],a[1],...,a[7]}   = %b   (前後顛倒)", reversed);
        $display("    {a[7:4], 4'b1010}      = %b   (夾常數)", mixed);

        $display("");
        $display("  ============================================================");
        $display("   三、for 迴圈 —— 它「複製硬體」，不是「跑 N 次」");
        $display("  ============================================================");
        $display("    a = %b", a);
        $display("");
        $display("    count_ones(a) = %0d   <- a 裡面有幾個 1", ones);
        $display("    reverse_bits(a) = %b  <- 用 for 寫的顛倒", reversed_f);
        $display("");
        $display("    ★ 上面兩個結果，跟第二節手寫 {} 的版本一模一樣：");
        $display("      for 版  = %b", reversed_f);
        $display("      手寫版  = %b", reversed);
        $display("");
        $display("    ★ 但它們「不是跑 8 次迴圈」——");
        $display("      綜合之後是 7 個加法器串成一條鏈（後面吃前面的結果），");
        $display("      訊號一路穿過去，不需要多個時脈，只要幾奈秒的傳播延遲。");

        $display("");
        $display("  ============================================================");
        $display("   四、換一組值再看一次");
        $display("  ============================================================");
        for (i = 0; i < 4; i = i + 1) begin
            case (i)
                0: a = 8'b0000_0000;
                1: a = 8'b1111_1111;
                2: a = 8'b1010_1010;
                3: a = 8'b0000_0001;
            endcase
            #10;
            $display("    a = %b  |  1的個數=%0d  |  顛倒後=%b  |  {2{a}}=%b",
                     a, ones, reversed_f, repeated);
        end

        $display("");
        $display("  ============================================================");
        $display("   五、Python 人最容易踩的三個坑");
        $display("  ============================================================");
        $display("    1. # 在 Verilog 是「延遲」，不是註解！註解用 //");
        $display("    2. {} 是「接線」，不是 dict 也不是程式區塊");
        $display("       程式區塊用 begin / end");
        $display("    3. 縮排完全不影響意義，Verilog 只認分號和 begin/end");
        $display("");

        #10 $finish;
    end

endmodule
