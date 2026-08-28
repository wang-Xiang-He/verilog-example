`timescale 1ns / 1ps

module operators_all_tb;

    reg  [3:0] a, b;

    wire [4:0] o_add, o_sub;
    wire [7:0] o_mul, o_pow;
    wire [3:0] o_div, o_mod, o_neg;
    wire [3:0] o_and, o_or, o_xor, o_xnor, o_not;
    wire       o_land, o_lor, o_lnot;
    wire       o_eq, o_ne, o_lt, o_gt, o_le, o_ge, o_ceq, o_cne;
    wire       o_rand, o_ror, o_rxor, o_rnand, o_rnor, o_rxnor;
    wire [3:0] o_shl, o_shr, o_ashl, o_ashr;

    operators_all uut (
        .a(a), .b(b),
        .o_add(o_add), .o_sub(o_sub), .o_mul(o_mul), .o_div(o_div),
        .o_mod(o_mod), .o_pow(o_pow), .o_neg(o_neg),
        .o_and(o_and), .o_or(o_or), .o_xor(o_xor), .o_xnor(o_xnor), .o_not(o_not),
        .o_land(o_land), .o_lor(o_lor), .o_lnot(o_lnot),
        .o_eq(o_eq), .o_ne(o_ne), .o_lt(o_lt), .o_gt(o_gt),
        .o_le(o_le), .o_ge(o_ge), .o_ceq(o_ceq), .o_cne(o_cne),
        .o_rand(o_rand), .o_ror(o_ror), .o_rxor(o_rxor),
        .o_rnand(o_rnand), .o_rnor(o_rnor), .o_rxnor(o_rxnor),
        .o_shl(o_shl), .o_shr(o_shr), .o_ashl(o_ashl), .o_ashr(o_ashr)
    );

    task show;
        begin
        $display("");
        $display("=================================================================");
        $display("  a = %b (%0d)      b = %b (%0d)", a, a, b, b);
        $display("=================================================================");
        $display("  (1) 算術  ── 輸出跟輸入一樣寬或更寬");
        $display("      a + b   = %b (%0d)", o_add, o_add);
        $display("      a - b   = %b (%0d)   ← 借位時看到的是補數，不是負號",
                 o_sub, o_sub);
        $display("      a * b   = %b (%0d)", o_mul, o_mul);
        $display("      a / b   = %b (%0d)   ← 整數除法，小數丟掉", o_div, o_div);
        $display("      a %% b   = %b (%0d)", o_mod, o_mod);
        $display("      a ** 2  = %b (%0d)", o_pow, o_pow);
        $display("      -a      = %b (%0d)   ← 4 位元裡的 -a 就是 16-a", o_neg, o_neg);
        $display("");
        $display("  (2) 位元  ── 一位一位分別做，輸出 4 位元");
        $display("      a & b   = %b        a | b   = %b", o_and, o_or);
        $display("      a ^ b   = %b        a ~^ b  = %b", o_xor, o_xnor);
        $display("      ~a      = %b", o_not);
        $display("");
        $display("  (3) 邏輯  ── 整條線當一個真假值，輸出永遠 1 位元");
        $display("      a && b  = %b            a || b  = %b", o_land, o_lor);
        $display("      !a      = %b", o_lnot);
        $display("");
        $display("  (4) 關係  ── 輸出永遠 1 位元");
        $display("      a == b  = %b   a != b  = %b   a <  b  = %b", o_eq, o_ne, o_lt);
        $display("      a >  b  = %b   a <= b  = %b   a >= b  = %b", o_gt, o_le, o_ge);
        $display("      a === b = %b   a !== b = %b   ← 連 x/z 都要一樣（只能模擬）",
                 o_ceq, o_cne);
        $display("");
        $display("  (5) 縮減  ── 一整條線縮成 1 位元");
        $display("      &a  = %b    |a  = %b    ^a  = %b   ← ^a 就是 parity",
                 o_rand, o_ror, o_rxor);
        $display("      ~&a = %b    ~|a = %b    ~^a = %b", o_rnand, o_rnor, o_rxnor);
        $display("");
        $display("  (6) 位移  ── 輸出跟輸入一樣寬（移出去的位就沒了）");
        $display("      a <<  1 = %b (%0d)     a >>  1 = %b (%0d)",
                 o_shl, o_shl, o_shr, o_shr);
        $display("      a <<< 1 = %b (%0d)     a >>> 1 = %b (%0d)  ← 有號右移補符號位",
                 o_ashl, o_ashl, o_ashr, o_ashr);
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, operators_all_tb);

        // ① 課本上的經典組合：a=12, b=10
        a = 4'b1100; b = 4'b1010; #20 show;

        // ② 除得盡的例子：15 / 3 = 5 餘 0
        a = 4'b1111; b = 4'b0011; #20 show;

        // ③ a = 0：邏輯運算子和縮減運算子的差別最明顯
        a = 4'b0000; b = 4'b0101; #20 show;

        // ④ ★ b = 0：/ 和 % 整條變 x
        a = 4'b0110; b = 4'b0000; #20 show;

        // ⑤ 兩邊相等
        a = 4'b0111; b = 4'b0111; #20 show;

        // ⑥ ★ 含 x 的值：== 給不出答案（x），=== 敢說 1
        a = 4'b10x1; b = 4'b10x1; #20 show;

        $display("");
        $display("=================================================================");
        $display("  ★★ 三個 & 完全不同 —— 本週最需要記熟的一組");
        $display("=================================================================");
        a = 4'b1100; b = 4'b1010; #20;
        $display("      a=%b  b=%b", a, b);
        $display("      a & b  = %b   位元 AND：4 個 AND 閘，輸出 4 位元", o_and);
        $display("      a && b = %b        邏輯 AND：兩邊都非零，輸出 1 位元", o_land);
        $display("      &a     = %b        縮減 AND：a[3]&a[2]&a[1]&a[0]", o_rand);
        $display("");
        $display("  ★ >> 和 >>> 的差別（a=1100，當成有號數就是 -4）");
        $display("      a >>  1 = %b (無號 12 → 6，左邊補 0)", o_shr);
        $display("      a >>> 1 = %b (有號 -4 → -2，左邊補符號位 1)", o_ashr);
        $display("");
        $display("  ★ 只能模擬、不能合成的：===  !==  （硬體上沒有 x 這種電壓）");
        $display("");

        #20 $finish;
    end

endmodule
