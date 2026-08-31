`timescale 1ns / 1ps

module area_compare_tb;
    reg  [7:0] a, b, c;
    reg        sel;
    reg  [7:0] d;

    wire [8:0]  y_sb, y_sg;
    wire [11:0] y_mb, y_mg;
    wire        h_mb, h_mg;
    wire [2:0]  p_if, p_cz;

    integer i, e1, e2, e3, e4;

    share_bad   u_sb (.a(a), .b(b), .c(c), .sel(sel), .y(y_sb));
    share_good  u_sg (.a(a), .b(b), .c(c), .sel(sel), .y(y_sg));
    mul9_bad    u_mb (.a(a), .y(y_mb));
    mul9_good   u_mg (.a(a), .y(y_mg));
    match_bad   u_hb (.a(a), .hit(h_mb));
    match_good  u_hg (.a(a), .hit(h_mg));
    pri_ifelse  u_pi (.d(d), .y(p_if));
    pri_casez   u_pc (.d(d), .y(p_cz));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, area_compare_tb);
        e1 = 0; e2 = 0; e3 = 0; e4 = 0;

        $display("");
        $display("  ============================================================");
        $display("   先證明 A / B 版功能【完全相同】，再談面積");
        $display("  ============================================================");

        // ---- 第 1 組：資源共用 ----
        $display("");
        $display("  ===== 第 1 組：資源共用（隨機 5000 組）=====");
        for (i = 0; i < 5000; i = i + 1) begin
            a = $random; b = $random; c = $random; sel = $random;
            #1;
            if (y_sb !== y_sg) e1 = e1 + 1;
        end
        if (e1 == 0) $display("   ★ share_bad 和 share_good 輸出完全一致");
        else         $display("   [X] 有 %0d 組不同", e1);

        // ---- 第 2 組：乘以 9 ----
        $display("");
        $display("  ===== 第 2 組：乘以 9（窮舉 256 組）=====");
        for (i = 0; i < 256; i = i + 1) begin
            a = i[7:0]; #1;
            if (y_mb !== y_mg)  e2 = e2 + 1;
            if (y_mg !== a * 9) e2 = e2 + 1;
        end
        if (e2 == 0) $display("   ★ mul9_bad = mul9_good = a*9，全部 256 組一致");
        else         $display("   [X] 有 %0d 處不同", e2);

        // ---- 第 3 組：多值比對 ----
        $display("");
        $display("  ===== 第 3 組：多值比對（窮舉 256 組）=====");
        for (i = 0; i < 256; i = i + 1) begin
            a = i[7:0]; #1;
            if (h_mb !== h_mg) e3 = e3 + 1;
        end
        if (e3 == 0) $display("   ★ match_bad 和 match_good 完全一致");
        else         $display("   [X] 有 %0d 組不同", e3);

        // ---- 第 4 組：優先權編碼 ----
        $display("");
        $display("  ===== 第 4 組：優先權編碼（窮舉 256 組）=====");
        for (i = 0; i < 256; i = i + 1) begin
            d = i[7:0]; #1;
            if (p_if !== p_cz) e4 = e4 + 1;
        end
        if (e4 == 0) $display("   ★ pri_ifelse 和 pri_casez 完全一致");
        else         $display("   [X] 有 %0d 組不同", e4);

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   四組功能都證明一樣了。現在跑綜合看面積：");
        $display("");
        $display("       03_area_compare.bat");
        $display("");
        $display("   實測結果（Yosys 0.68 / iCE40）：");
        $display("");
        $display("     模組          LUT4  CARRY  總cells   結論");
        $display("     -------------------------------------------------------");
        $display("     share_bad      25    16      41");
        $display("     share_good     16     8      24    ★ 省 41%%  資源共用真的有用");
        $display("");
        $display("     mul9_bad       17     7      24");
        $display("     mul9_good       8     8      16    ★ 省 33%%  位移取代乘法");
        $display("");
        $display("     match_bad       3     0       3");
        $display("     match_good      3     0       3    ⚠️ 一模一樣，白忙一場");
        $display("");
        $display("     pri_ifelse      5     0       5");
        $display("     pri_casez       6     0       6    ⚠️ 反而【變大】了");
        $display("  ============================================================");
        $display("");
        $display("   ★★ 這四組要學到的東西（比省面積更重要）：");
        $display("");
        $display("     1. 【值得手動優化的】：");
        $display("        改變「電路結構」的事 —— 少一顆加法器、少一顆乘法器。");
        $display("        工具不會幫你重排資料流，這是設計者的責任。");
        $display("");
        $display("     2. 【不值得手動優化的】：");
        $display("        布林式化簡、常數傳播、共同子運算式。");
        $display("        工具做得比你好而且不會出錯，手動改只會讓程式碼變難讀。");
        $display("");
        $display("     3. ★ 所以正確的作法是：");
        $display("        先【照最好讀的方式寫】，跑一次綜合看報告，");
        $display("        真的太大再回頭針對「結構」動手。");
        $display("        一開始就為了省面積把程式碼寫得很扭曲，");
        $display("        通常省不到什麼，卻害自己以後看不懂。");
        $display("");
        $display("   ⚠️ 注意上表的 CARRY：mul9_good 的 CARRY 比 mul9_bad 還多一個。");
        $display("      省面積常常不是全面勝出，而是「這裡省、那裡多一點」。");
        $display("      要看的是【總 cells】和最後 nextpnr 報的使用率（第 17 週）。");
        $display("");
        #20 $finish;
    end
endmodule
