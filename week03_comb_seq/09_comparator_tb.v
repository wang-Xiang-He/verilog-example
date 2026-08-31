`timescale 1ns / 1ps

module comparator_tb;
    reg  [7:0] a, b;
    wire u_gt, u_eq, u_lt, s_gt, s_eq, s_lt, borrow, eq_cheap;
    wire [8:0] diff;
    integer i, err;

    comparator uut (.a(a), .b(b), .u_gt(u_gt), .u_eq(u_eq), .u_lt(u_lt),
                    .s_gt(s_gt), .s_eq(s_eq), .s_lt(s_lt),
                    .diff(diff), .borrow(borrow), .eq_cheap(eq_cheap));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, comparator_tb);
        err = 0;

        $display("");
        $display("  ===== 一、★ 同一組位元，有號和無號比出相反的答案 =====");
        $display("");
        $display("      a         b     | 無號        | 有號");
        $display("                      | a>b a= a<b  | a>b a= a<b   說明");
        $display("   -------------------+-------------+------------------------");

        a = 8'hF0; b = 8'h08; #10;    // 無號 240 vs 8 ; 有號 -16 vs 8
        $display("   %b %b |  %0d   %0d   %0d  |  %0d   %0d   %0d   無號240>8, 有號-16<8",
                 a, b, u_gt, u_eq, u_lt, s_gt, s_eq, s_lt);

        a = 8'h80; b = 8'h7F; #10;    // 無號 128 vs 127 ; 有號 -128 vs 127
        $display("   %b %b |  %0d   %0d   %0d  |  %0d   %0d   %0d   ★ 最極端的一組",
                 a, b, u_gt, u_eq, u_lt, s_gt, s_eq, s_lt);

        a = 8'h05; b = 8'h05; #10;
        $display("   %b %b |  %0d   %0d   %0d  |  %0d   %0d   %0d   相等時兩邊一樣",
                 a, b, u_gt, u_eq, u_lt, s_gt, s_eq, s_lt);

        $display("");
        $display("  ===== 二、用減法做比較（課本的作法）=====");
        $display("");
        $display("      a    b  |  a-b (9位元)  borrow | 意義");
        $display("   -----------+----------------------+------------");
        a = 8'd200; b = 8'd100; #10;
        $display("    %3d  %3d |  %b      %0d    | borrow=0 → a >= b", a, b, diff, borrow);
        a = 8'd100; b = 8'd200; #10;
        $display("    %3d  %3d |  %b      %0d    | borrow=1 → a <  b", a, b, diff, borrow);
        a = 8'd150; b = 8'd150; #10;
        $display("    %3d  %3d |  %b      %0d    | diff=0   → a == b", a, b, diff, borrow);

        $display("");
        $display("  ===== 三、便宜的相等比較器 =====");
        $display("");
        $display("   全部 256x256 = 65536 組都測 ...");
        for (i = 0; i < 65536; i = i + 1) begin
            a = i[15:8]; b = i[7:0]; #1;
            if (eq_cheap !== u_eq) err = err + 1;
        end
        if (err == 0)
            $display("   ★ ~|(a^b) 和 (a==b) 結果【完全一致】，0 個誤差");
        else
            $display("   [X] 有 %0d 組不一致", err);
        $display("");
        $display("     為什麼便宜？ ~|(a^b) 就只是 8 顆 XOR + 一棵 OR 樹，");
        $display("     不需要拉出一整排大小比較的邏輯。");
        $display("     只要判斷相不相等，就用這個寫法。");
        $display("");
        $display("   ★ 本範例最該記住的一句話：");
        $display("     比較器的 signed / unsigned 選錯，8'h80 和 8'h7F 誰大會判反。");
        $display("");
        #20 $finish;
    end
endmodule
