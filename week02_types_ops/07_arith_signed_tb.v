`timescale 1ns / 1ps

module arith_signed_tb;
    reg signed [7:0] sa, sb;
    reg        [7:0] ua, ub;

    wire signed  [8:0] s_add;   wire  [8:0] u_add;
    wire signed [15:0] s_mul;   wire [15:0] u_mul;
    wire signed  [7:0] s_div;   wire  [7:0] u_div;
    wire signed  [7:0] sar;     wire  [7:0] shr;
    wire s_lt, u_lt;
    wire signed [8:0] cast_s;   wire [8:0] cast_u;

    arith_signed uut (
        .sa(sa), .sb(sb), .ua(ua), .ub(ub),
        .s_add(s_add), .u_add(u_add),
        .s_mul(s_mul), .u_mul(u_mul),
        .s_div(s_div), .u_div(u_div),
        .sar(sar), .shr(shr),
        .s_lt(s_lt), .u_lt(u_lt),
        .cast_s(cast_s), .cast_u(cast_u)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, arith_signed_tb);

        //  0xF0 和 0x08 這兩組位元，從頭到尾都沒變過
        sa = 8'hF0;  ua = 8'hF0;      // 有號 -16   /  無號 240
        sb = 8'h08;  ub = 8'h08;      // 有號  +8   /  無號   8
        #10;

        $display("");
        $display("  ============================================================");
        $display("   餵進去的位元完全一樣：a = 8'hF0 = %b", ua);
        $display("                          b = 8'h08 = %b", ub);
        $display("   差別只在「宣告成 signed 沒有」");
        $display("  ============================================================");
        $display("");
        $display("                      當成有號數            當成無號數");
        $display("   -------------------------------------------------------");
        $display("   a 的值         %10d          %10d", sa, ua);
        $display("   b 的值         %10d          %10d", sb, ub);
        $display("   -------------------------------------------------------");
        $display("   a + b          %10d          %10d", s_add, u_add);
        $display("     位元圖案      %b               %b", s_add, u_add);
        $display("   a * b          %10d          %10d", s_mul, u_mul);
        $display("   a / b          %10d          %10d", s_div, u_div);
        $display("   a 右移一位     %10d          %10d", sar, shr);
        $display("     (>>> vs >>)   %b               %b", sar, shr);
        $display("   a < b ?        %10d          %10d", s_lt, u_lt);
        $display("   -------------------------------------------------------");
        $display("   $signed(ua)+sb = %d      $unsigned(sa)+ub = %d", cast_s, cast_u);
        $display("");
        $display("   ★ 三個重點：");
        $display("     1. 加法的低 8 位一模一樣（%b），只有第 9 位不同", s_add[7:0]);
        $display("        → 加減法的「電路」是同一個，差別只在怎麼看結果");
        $display("     2. 乘法差了十萬八千里（%d vs %d）", s_mul, u_mul);
        $display("        → 乘法的「電路」真的不一樣，選錯直接算錯");
        $display("     3. a<b 一個是 1 一個是 0 —— 比較器也會看 signed");
        $display("");

        //  再換一組：兩個都是負數
        sa = -8'sd100; ua = 8'd156;   // 8'h9C
        sb = -8'sd3;   ub = 8'd253;   // 8'hFD
        #10;
        $display("  ---- 換一組：a = 8'h9C, b = 8'hFD ----");
        $display("   有號： %d * %d = %d", sa, sb, s_mul);
        $display("   無號： %d * %d = %d", ua, ub, u_mul);
        $display("   ★ 負負得正，有號乘法出來是正的；無號直接爆到 %d", u_mul);
        $display("");

        #20 $finish;
    end
endmodule
