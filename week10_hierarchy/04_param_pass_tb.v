`timescale 1ns / 1ps

module param_pass_tb;
    reg clk, rst_n, en;

    //  ★ 同一份設計，實例化成三種寬度
    reg  [3:0]  din4;   wire [3:0]  acc4;   wire c4;
    reg  [7:0]  din8;   wire [7:0]  acc8;   wire c8;
    reg  [15:0] din16;  wire [15:0] acc16;  wire c16;

    wire [7:0] w4, w8, w16, ab4, ab8, ab16;
    wire [3:0]  max4;
    wire [7:0]  max8;
    wire [15:0] max16;

    integer i, err;

    param_accum #(.WIDTH(4))  u4  (.clk(clk), .rst_n(rst_n), .en(en), .din(din4),
                                   .acc(acc4), .cout(c4),
                                   .reported_width(w4), .reported_addr_bits(ab4),
                                   .reported_max(max4));

    param_accum #(.WIDTH(8))  u8  (.clk(clk), .rst_n(rst_n), .en(en), .din(din8),
                                   .acc(acc8), .cout(c8),
                                   .reported_width(w8), .reported_addr_bits(ab8),
                                   .reported_max(max8));

    param_accum #(.WIDTH(16)) u16 (.clk(clk), .rst_n(rst_n), .en(en), .din(din16),
                                   .acc(acc16), .cout(c16),
                                   .reported_width(w16), .reported_addr_bits(ab16),
                                   .reported_max(max16));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, param_pass_tb);
        clk = 0; rst_n = 0; en = 0;
        din4 = 0; din8 = 0; din16 = 0; err = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   參數往下傳：同一份程式碼，三種寬度");
        $display("  ============================================================");

        // ============================================================
        $display("");
        $display("  ===== 一、參數傳到底層之後長什麼樣 =====");
        $display("");
        $display("   實例  | WIDTH | clog2(WIDTH) | 最大值      | 生出幾顆 fa_cell");
        $display("   ------+-------+--------------+-------------+------------------");
        $display("    u4   |   %0d   |      %0d       | %b        |        %0d",
                 w4, ab4, max4, w4);
        $display("    u8   |   %0d   |      %0d       | %b    |        %0d",
                 w8, ab8, max8, w8);
        $display("    u16  |  %0d   |      %0d       | %b |       %0d",
                 w16, ab16, max16, w16);
        $display("");
        $display("   ★ 三個實例用的是【同一份原始碼】，");
        $display("     差別只在實例化時寫的 #(.WIDTH(n))。");

        // ============================================================
        $display("");
        $display("  ===== 二、實際跑一遍，確認三個都對 =====");
        $display("");
        $display("   每拍都加 3，看各自什麼時候繞圈");
        $display("");
        $display("   拍 | acc4(4bit) | acc8(8bit) | acc16(16bit) | c4 c8 c16");
        $display("   ---+------------+------------+--------------+-----------");
        din4 = 4'd3; din8 = 8'd3; din16 = 16'd3;
        en = 1;
        for (i = 1; i <= 8; i = i + 1) begin
            @(negedge clk);
            $display("   %2d |     %2d     |     %3d    |     %5d    |  %0d  %0d  %0d",
                     i, acc4, acc8, acc16, c4, c8, c16);
        end
        $display("");
        $display("   ★ acc4 加到 15 就繞回去了（4 位元只到 15），");
        $display("     acc8 和 acc16 還在慢慢爬。同一份程式碼，行為隨參數改變。");

        // ============================================================
        $display("");
        $display("  ===== 三、階層式路徑：確認底層真的被複製了 N 份 =====");
        $display("");
        $display("   u4 裡面 generate 出來的 fa_cell：");
        $display("     u4.u_add.bit_slice[0].u_fa.sum = %0d", u4.u_add.bit_slice[0].u_fa.sum);
        $display("     u4.u_add.bit_slice[1].u_fa.sum = %0d", u4.u_add.bit_slice[1].u_fa.sum);
        $display("     u4.u_add.bit_slice[3].u_fa.sum = %0d", u4.u_add.bit_slice[3].u_fa.sum);
        $display("");
        $display("   u16 裡面第 15 顆（u4 根本沒有這一顆）：");
        $display("     u16.u_add.bit_slice[15].u_fa.sum = %0d",
                 u16.u_add.bit_slice[15].u_fa.sum);
        $display("");
        $display("   ★ generate 出來的實例路徑長這樣：");
        $display("       模組.迴圈標籤[索引].實例名");
        $display("     所以 generate 的 begin 一定要給標籤（: bit_slice），");
        $display("     不給的話波形上會變成一堆看不懂的 $gen_block_1。");

        // ============================================================
        $display("");
        $display("  ===== 四、parameter vs localparam =====");
        $display("");
        $display("   parameter WIDTH = 8;        ← 可以從外面 #(.WIDTH(16)) 覆寫");
        $display("   localparam ADDR_BITS = ...  ← ★ 不能從外面改");
        $display("");
        $display("   規則：凡是【由別的參數算出來】的值，一律用 localparam。");
        $display("   理由：如果 ADDR_BITS 開放覆寫，別人可能傳進");
        $display("         WIDTH=16 但 ADDR_BITS=2 這種自相矛盾的組合，");
        $display("         而且【編譯不會報錯】—— 這種 bug 最難找。");
        $display("");
        $display("   ⚠️ 課本 11.3.1 提到的 defparam 覆寫法：");
        $display("        defparam u8.WIDTH = 16;");
        $display("      這是 Verilog-1995 的舊寫法，Verilog-2001 之後【不建議使用】，");
        $display("      SystemVerilog 更是直接標成 deprecated。一律用 #(.NAME(value))。");

        // ============================================================
        $display("");
        $display("  ------------------------------------------------------------");
        $display("   ★★ 本週練習題（課本 3.7 + 11.3）：");
        $display("     把 01_alu_hier 的 W 從 8 改成 16，");
        $display("     確認【只需要改一個數字】，四顆子模組都不用動。");
        $display("");
        #20 $finish;
    end
endmodule
