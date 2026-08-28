`timescale 1ns / 1ps

module xz_tb;

    reg  data, enable;
    wire undriven;              // ★ 這條線故意不接任何東西
    wire tri_out;
    wire [3:0] from_undriven;
    reg  [3:0] never_set;       // ★ 這個暫存器故意不給初值

    xz uut (
        .data(data), .enable(enable),
        .undriven_in(undriven),
        .tri_out(tri_out), .from_undriven(from_undriven)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, xz_tb);

        $display("");
        $display("  ===== z：高阻抗（線浮空，沒人在驅動）=====");

        data = 1; enable = 1; #20;
        $display("   enable=1 data=1  → tri_out = %b   （正常輸出）", tri_out);

        data = 0; enable = 1; #20;
        $display("   enable=1 data=0  → tri_out = %b   （正常輸出）", tri_out);

        data = 1; enable = 0; #20;
        $display("   enable=0         → tri_out = %b   ★ z！線被放掉了", tri_out);

        $display("");
        $display("  ===== x：未知（沒被設定過）=====");
        $display("   never_set        = %b   ★ x！reg 宣告了卻沒給值", never_set);
        $display("   沒接的線 undriven = %b   ★ z！wire 沒人驅動", undriven);
        $display("   z 也會傳染： {4{undriven}} = %b", from_undriven);
        $display("");

        never_set = 4'b0011; #20;
        $display("   給值之後 never_set = %b   （x 消失了）", never_set);
        $display("");
        $display("  ★★ 除錯口訣：");
        $display("     波形出現 x（紅色）→ 忘了給初值 / 忘了接 reset");
        $display("     波形出現 z（中線）→ 忘了接線 / 三態沒 enable");
        $display("");

        #20 $finish;
    end

endmodule
