`timescale 1ns / 1ps

module show_netlist_tb;
    reg  a, b, cin;
    wire sum, cout;

    reg  [1:0] a2, b2;
    reg        cin2;
    wire [1:0] sum2;
    wire       cout2;

    reg        clk, rst_n;
    wire [1:0] q;

    reg        sel;
    wire [1:0] ymux;

    integer i, err;

    fa       u_fa   (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));
    adder2   u_add2 (.a(a2), .b(b2), .cin(cin2), .sum(sum2), .cout(cout2));
    counter2 u_cnt  (.clk(clk), .rst_n(rst_n), .q(q));
    mux2     u_mux  (.a(a2), .b(b2), .sel(sel), .y(ymux));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, show_netlist_tb);
        clk = 0; rst_n = 0; err = 0;
        a = 0; b = 0; cin = 0; a2 = 0; b2 = 0; cin2 = 0; sel = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   先確認功能，再去看電路圖");
        $display("  ============================================================");

        $display("");
        $display("  ===== fa 全加器真值表 =====");
        $display("");
        $display("   a b cin | sum cout");
        $display("   --------+---------");
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i[2:0]; #1;
            $display("   %0d %0d  %0d  |  %0d    %0d", a, b, cin, sum, cout);
            if ({cout, sum} !== (a + b + cin)) err = err + 1;
        end

        $display("");
        $display("  ===== adder2 窮舉 4x4x2 = 32 組 =====");
        for (i = 0; i < 32; i = i + 1) begin
            {cin2, a2, b2} = i[4:0]; #1;
            if ({cout2, sum2} !== (a2 + b2 + cin2)) err = err + 1;
        end
        $display("   %s", (err == 0) ? "OK" : "有錯");

        $display("");
        $display("  ===== counter2 數 6 拍 =====");
        $write("   ");
        for (i = 0; i < 6; i = i + 1) begin
            @(negedge clk);
            $write("%0d ", q);
        end
        $display("  ← 2 位元，數到 3 就繞回 0");

        $display("");
        if (err == 0) $display("   ★ 功能全部正確");
        else          $display("   [X] 有 %0d 處錯誤", err);

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   現在跑 04_show_netlist.bat 產生電路圖");
        $display("  ============================================================");
        $display("");
        $display("   會產生 6 個 .dot 檔。這台機器沒裝 graphviz，用線上看最快：");
        $display("     https://dreampuf.github.io/GraphvizOnline/");
        $display("     把 .dot 內容整個貼進去就會畫出來。");
        $display("");
        $display("   ★★ 三張圖一定要看：");
        $display("");
        $display("     1. fa_rtl.dot  vs  fa_gate.dot");
        $display("        綜合【前】：看得到 XOR、AND、OR 這些你寫的東西");
        $display("        綜合【後】：全部不見了，只剩 SB_LUT4");
        $display("        → 因為 iCE40 裡面【根本沒有 AND 閘】，");
        $display("          只有 4 輸入查表 (LUT)。任何 4 變數以內的布林函數，");
        $display("          都是查表查出來的，不是用閘接出來的。");
        $display("");
        $display("     2. adder2_rtl.dot");
        $display("        看得到【兩個 fa 方塊】和中間那條進位線。");
        $display("        → 這就是第 10 週的階層式設計在工具眼中的樣子。");
        $display("        （如果先跑 flatten，這兩個方塊就會被打散、消失）");
        $display("");
        $display("     3. counter2_rtl.dot");
        $display("        ★ 找那條【從 DFF 輸出繞回加法器輸入】的線。");
        $display("          那條回授線就是「記憶」的來源 ——");
        $display("          組合邏輯的圖裡永遠不會有迴圈，循序邏輯一定有。");
        $display("");
        $display("   ⚠️ 圖看不懂很正常。重點不是每個節點都認得，");
        $display("      而是建立「我寫的文字真的變成了一張電路」這個直覺。");
        $display("");
        #20 $finish;
    end
endmodule
