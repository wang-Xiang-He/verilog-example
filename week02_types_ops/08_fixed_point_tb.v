`timescale 1ns / 1ps

module fixed_point_tb;
    reg  [7:0] a, qa, qb;
    wire [8:0] a_x1p5;
    wire [9:0] a_x3;
    wire [7:0] a_div9_ref, a_div9_fast;
    wire [8:0]  q_add;
    wire [15:0] q_mul_full;
    wire [7:0]  q_mul_trunc, q_mul_round;

    integer i, err_div, err_trunc, err_round;
    real    fa, fb, fexact, ftrunc, fround;

    fixed_point uut (
        .a(a), .a_x1p5(a_x1p5), .a_x3(a_x3),
        .a_div9_ref(a_div9_ref), .a_div9_fast(a_div9_fast),
        .qa(qa), .qb(qb), .q_add(q_add), .q_mul_full(q_mul_full),
        .q_mul_trunc(q_mul_trunc), .q_mul_round(q_mul_round)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, fixed_point_tb);
        qa = 8'h00; qb = 8'h00;

        // ============================================================
        $display("");
        $display("  ===== 一、1.5 倍與 3 倍（課本 7.4.5）=====");
        $display("");
        $display("     a  |  a+(a>>1)  應該是   |  (a<<1)+a  應該是");
        $display("   -----+---------------------+--------------------");
        for (i = 0; i < 256; i = i + 40) begin
            a = i[7:0]; #5;
            $display("   %4d |   %5d     %5d     |   %5d     %5d",
                     a, a_x1p5, (a*3)/2, a_x3, a*3);
        end
        $display("");
        $display("   ★ 1.5a 用整數位移做，小數點以下會被丟掉（無條件捨去）");
        $display("");

        // ============================================================
        $display("  ===== 二、除以 9 不用除法器（課本 7.4.6）=====");
        $display("");
        err_div = 0;
        for (i = 0; i < 256; i = i + 1) begin
            a = i[7:0]; #1;
            if (a_div9_fast !== a_div9_ref) begin
                err_div = err_div + 1;
                if (err_div <= 5)
                    $display("   [X] a=%0d  快速式=%0d  正確=%0d", a, a_div9_fast, a_div9_ref);
            end
        end
        $display("     全部 256 個 a 值都測過");
        if (err_div == 0)
            $display("     ★ (a*57)>>9 和 a/9 結果【完全一致】，0 個誤差");
        else
            $display("     [X] 有 %0d 個不一致", err_div);
        $display("");
        $display("     為什麼是 57？   1/9 = 0.1111...");
        $display("                     0.1111... x 512 = 56.9  →  取 57");
        $display("     為什麼能省？    乘常數 57 = a<<5 + a<<4 + a<<3 + a");
        $display("                     四次位移相加，比一顆除法器便宜非常多");
        $display("");

        // ============================================================
        $display("  ===== 三、Q4.4 定點小數乘法與四捨五入（7.4.7 / 7.6）=====");
        $display("");
        $display("   Q4.4 = 8 位元，前 4 位整數、後 4 位小數，1 個 LSB = 1/16 = 0.0625");
        $display("");
        $display("      qa      qb   |  精確值  | 直接截斷  誤差   | 四捨五入  誤差");
        $display("   ---------------+----------+-----------------+-----------------");
        for (i = 0; i < 8; i = i + 1) begin
            //  刻意讓乘積 < 16，才不會超出 Q4.4 的表示範圍
            qa = 8'd19 + i[7:0] * 8'd5;     // 1.1875 ~ 3.3750
            qb = 8'd11 + i[7:0] * 8'd4;     // 0.6875 ~ 2.4375
            #5;
            fa     = qa / 16.0;
            fb     = qb / 16.0;
            fexact = fa * fb;
            ftrunc = q_mul_trunc / 16.0;
            fround = q_mul_round / 16.0;
            $display("   %6.4f  %6.4f |  %7.4f | %7.4f  %+6.4f | %7.4f  %+6.4f",
                     fa, fb, fexact, ftrunc, ftrunc-fexact, fround, fround-fexact);
        end
        $display("");
        $display("   ★ 截斷那一欄的誤差【全部都是負的】—— 永遠只會少算，誤差會累積");
        $display("     四捨五入那一欄可正可負，平均誤差大約是截斷的一半");
        $display("");
        $display("   算式：q_mul_round = (qa*qb + 8) >> 4");
        $display("                                ^^^ 這個 8 就是半個 LSB：2^(4-1)");
        $display("");

        //  ---- 溢位示範 ----
        $display("   ---- 但是要小心溢位 ----");
        qa = 8'b0100_0000;   // 4.0
        qb = 8'b0101_0000;   // 5.0
        #5;
        $display("   %0.4f x %0.4f = %0.4f，但 Q4.4 截回來只剩 %0.4f",
                 qa/16.0, qb/16.0, (qa/16.0)*(qb/16.0), q_mul_trunc/16.0);
        $display("   ★ Q4.4 最大只能表示 15.9375，20.0 放不下 → 高位被砍掉");
        $display("     完整的 Q8.8 結果其實是對的：%0.4f", q_mul_full/256.0);
        $display("     所以「要不要砍回 Q4.4」是設計者要自己判斷的事");
        $display("");

        // ============================================================
        $display("  ===== 四、Q4.4 加法 =====");
        qa = 8'b0011_1000;   // 3.5
        qb = 8'b0001_0100;   // 1.25
        #5;
        $display("   %b (=%0.4f) + %b (=%0.4f) = %b (=%0.4f)",
                 qa, qa/16.0, qb, qb/16.0, q_add, q_add/16.0);
        $display("   ★ 小數點位置一樣時，加法直接加就好，跟整數加法是同一顆電路");
        $display("");

        #20 $finish;
    end
endmodule
