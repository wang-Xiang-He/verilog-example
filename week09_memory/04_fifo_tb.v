`timescale 1ns / 1ps

module fifo_tb;
    localparam AW = 3, DW = 8;

    reg clk = 0, rst, wr_en, rd_en;
    reg  [DW-1:0] wr_data;
    wire [DW-1:0] rd_data;
    wire full, empty;
    wire [AW:0] count;

    integer i, errors = 0;

    fifo #(.AW(AW), .DW(DW)) uut (
        .clk(clk), .rst(rst),
        .wr_en(wr_en), .wr_data(wr_data), .full(full),
        .rd_en(rd_en), .rd_data(rd_data), .empty(empty),
        .count(count)
    );
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, fifo_tb);

        rst = 1; wr_en = 0; rd_en = 0; wr_data = 0;
        @(posedge clk); @(posedge clk); #1 rst = 0;

        $display("");
        $display("   FIFO 深度 = %0d", 2**AW);
        $display("");
        $display("   ===== 連續寫入 10 筆，看什麼時候滿 =====");
        $display("    動作     count  empty  full");
        $display("   -------------------------------");

        for (i = 0; i < 10; i = i + 1) begin
            wr_en = 1; wr_data = 8'hA0 + i[7:0]; rd_en = 0;
            @(posedge clk); #1;
            wr_en = 0;
            if (i >= 8)
                $display("    寫 %h     %0d      %b      %b   <- 滿了，寫不進去",
                         8'hA0 + i[7:0], count, empty, full);
            else
                $display("    寫 %h     %0d      %b      %b",
                         8'hA0 + i[7:0], count, empty, full);
        end

        $display("");
        $display("   ===== 連續讀出 10 筆，看什麼時候空 =====");
        for (i = 0; i < 10; i = i + 1) begin
            rd_en = 1; wr_en = 0;
            @(posedge clk); #1;
            rd_en = 0;
            if (i < 8) begin
                if (rd_data !== (8'hA0 + i[7:0])) begin
                    $display("    [X] 第 %0d 筆讀到 %h，應該是 %h",
                             i, rd_data, 8'hA0 + i[7:0]);
                    errors = errors + 1;
                end else begin
                    $display("    讀 %h     %0d      %b      %b   順序正確",
                             rd_data, count, empty, full);
                end
            end else begin
                $display("    讀 --      %0d      %b      %b   <- 空了，讀不出東西",
                         count, empty, full);
            end
        end

        $display("");
        $display("   ===== 邊寫邊讀 =====");
        for (i = 0; i < 6; i = i + 1) begin
            wr_en = 1; wr_data = 8'h50 + i[7:0]; rd_en = (i > 0);
            @(posedge clk); #1;
            $display("    同時 寫 %h / 讀 %h    count=%0d",
                     8'h50 + i[7:0], rd_data, count);
        end
        wr_en = 0; rd_en = 0;
        @(posedge clk); #1;

        $display("");
        if (errors == 0) $display("   >>> 資料順序全部正確！");
        else             $display("   >>> 有 %0d 個錯", errors);
        $display("");
        $display("  ★★ 空 / 滿怎麼判斷（FIFO 唯一的難點）：");
        $display("     指標多留一個位元（wrap bit）");
        $display("       位址部分相同 + wrap 相同 -> 空");
        $display("       位址部分相同 + wrap 不同 -> 滿");
        $display("");
        $display("     沒有這個技巧，「全空」和「全滿」的指標長得一模一樣，分不出來。");
        $display("");
        $display("  ★ 波形重點：count 這條線的起伏，");
        $display("    以及 full / empty 各在哪一拍跳起來");
        $display("");
        $finish;
    end
endmodule
