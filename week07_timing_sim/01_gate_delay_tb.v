`timescale 1ns / 100ps

module gate_delay_tb;
    reg a, b, c;
    wire y_ideal, y_real;

    gate_delay uut (.a(a), .b(b), .c(c), .y_ideal(y_ideal), .y_real(y_real));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, gate_delay_tb);

        $monitor("   t=%3t  a=%b b=%b c=%b | 理想=%b  真實=%b",
                 $time, a, b, c, y_ideal, y_real);

        a = 0; b = 0; c = 0;
        #20 a = 1; b = 1;      // 這時 y 應該變 1
        #20 a = 0;             // 這時 y 應該變 0
        #20 c = 1;
        #20 c = 0;
        #30;

        $display("");
        $display("  ★ 看波形：y_real 永遠比 y_ideal 晚 4ns（兩顆閘各 2ns）");
        $display("");
        $display("  ★ 這 4ns 就是這條路徑的「傳播延遲」。");
        $display("    整個電路裡最長的那條路徑叫「關鍵路徑」，");
        $display("    它決定了這個設計最快能跑幾 MHz：");
        $display("");
        $display("        最高時脈 = 1 / 關鍵路徑延遲");
        $display("        例如關鍵路徑 4ns → 最高 250 MHz");
        $display("");
        $display("  ★ 功能模擬（前 6 週做的）完全看不到這件事，");
        $display("    因為它假設所有閘都是瞬間反應。");
        $display("");
        $finish;
    end
endmodule
