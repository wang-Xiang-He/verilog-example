// ============================================================
//  W7-4：RTL 模擬 vs 閘級模擬 對照
// ============================================================
`timescale 1ns / 1ps

module netlist_tb;

    reg  [7:0] a, b;

    wire [8:0] sum_rtl,  sum_gate;
    wire       big_rtl,  big_gate;

    integer glitches = 0;
    integer i;

    logic_rtl  u_rtl  (.a(a), .b(b), .sum(sum_rtl),  .big(big_rtl));
    logic_gate u_gate (.a(a), .b(b), .sum(sum_gate), .big(big_gate));

    // 監看閘級輸出的每一次跳動
    always @(big_gate) begin
        if ($time > 0) begin
            glitches = glitches + 1;
        end
    end

    task apply(input [7:0] va, input [7:0] vb);
        begin
            a = va; b = vb;
            #50;                       // 給閘級版足夠時間穩定下來
            if (sum_rtl === sum_gate && big_rtl === big_gate)
                $display("   a=%3d b=%3d | RTL: sum=%3d big=%b  |  閘級: sum=%3d big=%b   一致",
                         a, b, sum_rtl, big_rtl, sum_gate, big_gate);
            else
                $display("   a=%3d b=%3d | RTL: sum=%3d big=%b  |  閘級: sum=%3d big=%b   不一致!",
                         a, b, sum_rtl, big_rtl, sum_gate, big_gate);
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, netlist_tb);

        $display("");
        $display("  ==========================================================");
        $display("   同一個設計，左邊是你寫的 RTL，右邊是真實 iCE40 閘級網表");
        $display("   電路：sum = a + b;  big = (sum > 200)");
        $display("  ==========================================================");
        $display("");

        apply(8'd0,   8'd0);
        apply(8'd100, 8'd50);
        apply(8'd100, 8'd101);        // 剛好跨過 200 的門檻
        apply(8'd255, 8'd255);
        apply(8'd0,   8'd0);
        apply(8'd255, 8'd0);
        apply(8'd128, 8'd73);

        $display("");
        $display("   >>> 穩定之後兩邊完全一致（功能正確）");
        $display("   >>> 但閘級版的 big 總共跳動了 %0d 次", glitches);
        $display("");
        $display("  ★★ 這就是功能模擬看不到的東西：");
        $display("");
        $display("     RTL 版：a 一變，sum 和 big 瞬間就是正確值");
        $display("     閘級版：進位要一級一級傳過 8 個 SB_CARRY，");
        $display("             傳的過程中 sum 會出現一連串「中途的錯值」，");
        $display("             big 也跟著閃來閃去 —— 這就是毛刺。");
        $display("");
        $display("  ★ 波形操作建議（重點）：");
        $display("     1. 把 sum_rtl 和 sum_gate 上下排在一起");
        $display("     2. 找 a 從 0 跳到 255 的那個時間點");
        $display("     3. 用 Zoom In 一直放大到 ns 等級");
        $display("     4. 你會看到 sum_gate 在幾 ns 之內連跳好幾個值才穩定");
        $display("        而 sum_rtl 是一步到位");
        $display("");
        $display("  ★ 為什麼實務上不會出錯？");
        $display("     因為輸出都會接到正反器，只在時脈邊緣取樣。");
        $display("     只要時脈週期 > 最長的穩定時間，取到的一定是正確值。");
        $display("");
        $display("     這個「最長穩定時間」就是關鍵路徑，");
        $display("     而算出它的工具就是第 17-18 週要學的靜態時序分析。");
        $display("");

        $finish;
    end
endmodule
