`timescale 1ns / 1ps

module operators_tb;

    reg  [3:0] a, b;
    wire [4:0] o_add, o_sub;
    wire [7:0] o_mul;
    wire [3:0] o_and, o_or, o_xor, o_not, o_shl, o_shr;
    wire       o_land, o_lnot, o_eq, o_lt, o_red_and, o_red_or, o_red_xor;

    operators uut (
        .a(a), .b(b),
        .o_add(o_add), .o_sub(o_sub), .o_mul(o_mul),
        .o_and(o_and), .o_or(o_or), .o_xor(o_xor), .o_not(o_not),
        .o_land(o_land), .o_lnot(o_lnot),
        .o_eq(o_eq), .o_lt(o_lt),
        .o_red_and(o_red_and), .o_red_or(o_red_or), .o_red_xor(o_red_xor),
        .o_shl(o_shl), .o_shr(o_shr)
    );

    task show;
        begin
            $display("");
            $display("  a=%b(%0d)  b=%b(%0d)", a, a, b, b);
            $display("   算術  : a+b=%0d   a-b=%0d   a*b=%0d", o_add, o_sub, o_mul);
            $display("   位元  : a&b=%b  a|b=%b  a^b=%b  ~a=%b", o_and, o_or, o_xor, o_not);
            $display("   邏輯  : a&&b=%b  !a=%b", o_land, o_lnot);
            $display("   關係  : a==b=%b  a<b=%b", o_eq, o_lt);
            $display("   縮減  : &a=%b  |a=%b  ^a=%b", o_red_and, o_red_or, o_red_xor);
            $display("   位移  : a<<1=%b(%0d)  a>>1=%b(%0d)", o_shl, o_shl, o_shr, o_shr);
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, operators_tb);

        a = 4'b1100; b = 4'b1010; #20 show;
        a = 4'b1111; b = 4'b0001; #20 show;
        a = 4'b0000; b = 4'b0101; #20 show;
        a = 4'b0111; b = 4'b0111; #20 show;

        $display("");
        $display("  ★ 注意 a&b 和 a&&b 完全不同：");
        $display("    a&b  是 4 個 AND 閘，輸出 4 位元");
        $display("    a&&b 是「a 非零 且 b 非零」，輸出 1 位元");
        $display("");

        #20 $finish;
    end

endmodule
