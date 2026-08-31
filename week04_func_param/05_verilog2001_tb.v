`timescale 1ns / 1ps

module v2001_demo_tb;
    localparam W = 8;

    reg          clk, rst_n;
    reg  [W-1:0] a, b;
    reg  [3:0]   idx;

    wire [W-1:0] pow_out, const_out, md_out, sens_out;
    wire [3:0]   part_out;
    wire         signed_ok;

    reg  [1:0]   sel;
    reg  [3:0]   d0, d1, d2, d3;
    wire [3:0]   y, kept;

    integer i;

    //  13.16 具名參數傳遞
    v2001_demo #(.W(W), .MODE("FAST")) uut (
        .clk(clk), .rst_n(rst_n), .a(a), .b(b), .idx(idx),
        .pow_out(pow_out), .part_out(part_out), .const_out(const_out),
        .md_out(md_out), .sens_out(sens_out), .signed_ok(signed_ok)
    );

    attr_demo attr (.sel(sel), .d0(d0), .d1(d1), .d2(d2), .d3(d3),
                    .y(y), .kept(kept));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, v2001_demo_tb);
        clk = 0; rst_n = 0;
        a = 8'b1010_0101; b = 8'b1100_0011; idx = 0;
        d0 = 4'h1; d1 = 4'h2; d2 = 4'h4; d3 = 4'h8; sel = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   Verilog 2001 增強特色（課本第 13 章）");
        $display("  ============================================================");

        // --------------------------------------------------------
        $display("");
        $display("  ===== 13.3  Constant Function（常數函式）=====");
        $display("");
        $display("   參數 W = %0d", W);
        $display("   clog2(W) 在【編譯時期】算出 = %0d", const_out);
        $display("   ★ 以前「8 個位址要幾條線」只能自己心算填 3，");
        $display("     現在可以寫成 clog2(W)，改 W 的時候不用再回頭改。");

        // --------------------------------------------------------
        $display("");
        $display("  ===== 13.8  Power Operator ** =====");
        $display("");
        $display("   2 ** 5 = %0d", pow_out);
        $display("   ⚠️ 只有【指數是常數】才合成得出來；");
        $display("     指數是變數的話工具會直接報錯。");

        // --------------------------------------------------------
        $display("");
        $display("  ===== 13.4  Indexed Part Select  +: =====");
        $display("");
        $display("   wide = {a[3:0], b[3:0]} = %b", {a[3:0], b[3:0]});
        $display("");
        $display("   idx | wide[idx +: 4] | 說明");
        $display("   ----+----------------+------------------------");
        for (i = 0; i < 5; i = i + 1) begin
            idx = i[3:0]; #5;
            $display("    %0d  |      %b      | 從第 %0d 位往上取 4 位", idx, part_out, idx);
        end
        $display("");
        $display("   ★ 舊寫法 wide[idx+3 : idx] 是【違法】的，因為切片界限必須是常數。");
        $display("     +: 就是為了解決這件事而生的，起點可以是變數。");

        // --------------------------------------------------------
        $display("");
        $display("  ===== 13.5  多維陣列 =====");
        $display("");
        $display("   table2d[r][c] = r*16 + c");
        $display("");
        $display("   idx | [r][c]  | md_out");
        $display("   ----+---------+--------");
        for (i = 0; i < 6; i = i + 1) begin
            idx = i[3:0]; #5;
            $display("   %2d  | [%0d][%0d]  |  %3d", idx, idx[3:2], idx[1:0], md_out);
        end
        $display("");
        $display("   ★ Verilog-1995 只能宣告一維記憶體 reg [7:0] m [0:255];");
        $display("     2001 開始才能 reg [7:0] m [0:3][0:3];");

        // --------------------------------------------------------
        $display("");
        $display("  ===== 13.7  有號數運算延伸 =====");
        $display("");
        $display("   wire signed 宣告 vs $signed() 轉型，結果一致？ %0d（1=是）", signed_ok);
        $display("   ★ Verilog-1995 只有 integer 是有號的，reg/wire 一律無號。");
        $display("     第 2 週的 07_arith_signed 能寫得出來，靠的就是這個 2001 功能。");

        // --------------------------------------------------------
        $display("");
        $display("  ===== 13.10 / 13.11  敏感度列表 =====");
        $display("");
        a = 8'hFF; b = 8'h0F; #5;
        $display("   always @(a, b) 逗號寫法： a^b = %h", sens_out);
        $display("");
        $display("   三代寫法對照：");
        $display("     1995：always @(a or b or c or d)   ← 漏一個就生 latch");
        $display("     2001：always @(a, b, c, d)         ← 只是逗號比較好看");
        $display("     2001：always @(*)                  ← ★ 讓工具自己抓，永遠不會漏");
        $display("   結論：一律用 @(*)。");

        // --------------------------------------------------------
        $display("");
        $display("  ===== 13.25 Attribute（★ 課綱說的「屬性」）=====");
        $display("");
        $display("   sel | y   | 說明");
        $display("   ----+-----+---------------------------");
        for (i = 0; i < 4; i = i + 1) begin
            sel = i[1:0]; #5;
            $display("    %0d  | %h   | (* full_case, parallel_case *) 修飾的 case", sel, y);
        end
        $display("");
        $display("   (* keep *) 保留下來的除錯線 kept = d0^d1 = %h", kept);
        $display("");
        $display("   語法：(* 屬性名 *) 或 (* 屬性名 = 值 *)，寫在被修飾的東西【前面】");
        $display("");
        $display("   常用的幾個：");
        $display("     (* keep *)                 別把這條線最佳化掉（除錯用）");
        $display("     (* full_case *)            我保證 case 列全了");
        $display("     (* parallel_case *)        我保證各條件互斥");
        $display("     (* ram_style = \"block\" *)  這塊記憶體請用 BRAM（第 9 週）");
        $display("");
        $display("   ★ 屬性【不影響模擬】，只影響綜合。iverilog 直接當註解略過，");
        $display("     yosys 才會真的照做 —— 所以模擬對不代表合成後也對。");
        $display("");
        $display("   ⚠️ full_case / parallel_case 要非常小心：");
        $display("      你講的如果不是真的，模擬和合成後的電路會【不一樣】。");
        $display("      這種 bug 極難抓。除非很確定，否則寧可老實寫 default。");

        // --------------------------------------------------------
        $display("");
        $display("  ===== 13.1  Configuration（★ 課綱說的「組態」）=====");
        $display("");
        $display("   Configuration 是用來解決這個問題的：");
        $display("     同一個模組有好幾種版本（行為模型 / RTL / 閘級網表），");
        $display("     要在【不改設計檔】的前提下，指定這次模擬要用哪一版。");
        $display("");
        $display("   語法長這樣（寫在獨立的 .v 檔裡）：");
        $display("");
        $display("     config cfg_rtl;");
        $display("       design work.top;");
        $display("       default liblist rtl_lib;");
        $display("       instance top.u_alu liblist gate_lib;   // 這一顆改用閘級");
        $display("     endconfig");
        $display("");
        $display("   ⚠️ iverilog【不支援】config，這是商用工具（Vivado/ModelSim）的功能，");
        $display("      所以本檔只講語法不實跑。第 7 週的 04_netlist 想做的事情一樣，");
        $display("      但我們是用「換檔案編譯」的土法達成的。");

        // --------------------------------------------------------
        $display("");
        $display("  ============================================================");
        $display("   第 13 章共 34 個特色 70 頁，這裡只挑了實務會用到的。");
        $display("   其餘（SDF、PLA 建模、負脈衝偵測…）查課本 PDF p.451-524。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
