`timescale 1ns / 1ps

module mem_expand_tb;
    reg        clk, we;
    reg  [3:0] a4, d4;
    reg  [7:0] d8;
    reg  [4:0] a5;
    wire [7:0] q_bitexp, q_rom;
    wire [3:0] q_wordexp;

    integer i, err;

    mem_expand uut (.clk(clk), .we(we), .a4(a4), .d8(d8), .q_bitexp(q_bitexp),
                    .a5(a5), .d4(d4), .q_wordexp(q_wordexp), .q_rom(q_rom));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, mem_expand_tb);
        clk = 0; we = 0; a4 = 0; d4 = 0; d8 = 0; a5 = 0;
        err = 0;

        // ============================================================
        $display("");
        $display("  ===== 一、位元擴充：兩顆 16x4 拼成 16x8（課本 12.2.1）=====");
        $display("");
        $display("   位址線兩顆接一樣，資料線一顆高 4 位、一顆低 4 位");
        $display("");

        //  ★ 激勵一律在【負緣】改，不要在正緣改。
        //    在正緣改會和 always @(posedge clk) 搶同一個時間點，
        //    誰先誰後不確定 —— 這是測試平台最常見的競爭錯誤。
        we = 1;
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);
            a4 = i[3:0];
            d8 = 8'hA0 + i[7:0];
        end
        @(negedge clk);
        we = 0;

        $display("   位址 | 寫進去 | 讀回來 | 高4位(hi顆)  低4位(lo顆)");
        $display("   -----+--------+--------+-------------------------");
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);          // 先把位址放好
            a4 = i[3:0];
            @(negedge clk);          // 等一個正緣過去，同步讀出的值才會到
            if (q_bitexp !== (8'hA0 + i[7:0])) err = err + 1;
            $display("     %0d  |   %h   |   %h   |    %h            %h",
                     a4, 8'hA0 + i[7:0], q_bitexp, q_bitexp[7:4], q_bitexp[3:0]);
        end
        $display("");
        $display("   ★ 兩顆各存一半，讀出來自動併成 8 位元。");
        $display("     位址範圍【沒有變】，還是 0~15；變寬的是每一格的容量。");

        // ============================================================
        $display("");
        $display("  ===== 二、字組擴充：兩顆 16x4 拼成 32x4（課本 12.2.2）=====");
        $display("");
        $display("   資料線共用，addr[4] 拿來當選片訊號");
        $display("");

        we = 1;
        for (i = 0; i < 32; i = i + 1) begin
            @(negedge clk);
            a5 = i[4:0];
            d4 = i[3:0] ^ 4'hF;
        end
        @(negedge clk);
        we = 0;

        $display("   位址 | addr[4] | 選到哪顆 | 寫進去 | 讀回來");
        $display("   -----+---------+----------+--------+--------");
        for (i = 0; i < 32; i = i + 4) begin
            @(negedge clk);
            a5 = i[4:0];
            @(negedge clk);
            if (q_wordexp !== (i[3:0] ^ 4'hF)) err = err + 1;
            if (a5[4] == 1'b0)
                $display("    %2d  |    %0d    |  blk0    |   %h    |   %h",
                         a5, a5[4], i[3:0] ^ 4'hF, q_wordexp);
            else
                $display("    %2d  |    %0d    |  blk1    |   %h    |   %h",
                         a5, a5[4], i[3:0] ^ 4'hF, q_wordexp);
        end
        $display("");
        $display("   ★ 每格還是 4 位元【沒有變寬】，變多的是格數：16 → 32。");
        $display("     兩顆的 dout 接在同一條線上，靠三態閘 + 選片避免打架。");
        $display("     （這就是第 3 週 11_tristate_inout 的實際用途）");

        // ============================================================
        $display("");
        $display("  ===== 三、ROM 的字組擴充（課本 12.5.2）=====");
        $display("");
        $display("   下半部 ROM 內容從 0x10 開始，上半部從 0xA0 開始");
        $display("");
        $display("   位址 | q_rom | 來自");
        $display("   -----+-------+--------");
        for (i = 0; i < 32; i = i + 3) begin
            a5 = i[4:0]; #5;
            if (a5[4] == 1'b0)
                $display("    %2d  |  %h   | r0 (下半)", a5, q_rom);
            else
                $display("    %2d  |  %h   | r1 (上半)", a5, q_rom);
        end
        $display("");
        $display("   ★ 位址跨過 16 的那一刻，資料從 0x1x 跳成 0xAx");
        $display("     —— 那就是選片訊號切換的瞬間。");

        // ============================================================
        $display("");
        $display("  ------------------------------------------------------------");
        if (err == 0) $display("   ★ 全部讀寫比對通過，0 個錯");
        else          $display("   [X] 有 %0d 處不符", err);
        $display("");
        $display("   兩種擴充一句話記起來：");
        $display("     位元擴充 → 每格【變寬】。位址共用，資料併起來。");
        $display("     字組擴充 → 格數【變多】。資料共用，多一條位址當選片。");
        $display("");
        $display("   ⚠️ 實務提醒：在 FPGA 上你不會手動做這件事，");
        $display("      直接寫 reg [7:0] mem [0:31]; 綜合工具會自己去湊 BRAM。");
        $display("      但考試會考，而且做 ASIC 用現成記憶體巨集時真的要自己拼。");
        $display("");
        #20 $finish;
    end
endmodule
