`timescale 1ns / 1ps

module rom_tb;
    reg clk = 0;
    reg  [3:0] addr;
    wire [7:0] data_async, data_sync;
    integer i;

    rom uut (.clk(clk), .addr(addr), .data_async(data_async), .data_sync(data_sync));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, rom_tb);

        $display("");
        $display("   這個 ROM 存的是 0~15 的平方（用十六進位存）");
        $display("");
        $display("   位址 | 非同步讀  同步讀   (十進位)");
        $display("  ------+-----------------------------");

        addr = 0;
        @(posedge clk); #1;

        for (i = 0; i < 16; i = i + 1) begin
            addr = i[3:0];
            #1;                                  // 讓非同步輸出穩定
            @(posedge clk); #1;                  // 等同步輸出出來
            $display("    %2d   |   %h        %h      %0d", i, data_async, data_sync, data_sync);
        end

        $display("");
        $display("  ★★ 看波形最重要的一點：");
        $display("     data_async 跟 addr 同時變（純組合邏輯）");
        $display("     data_sync  比 addr 晚一個時脈（多了一顆正反器）");
        $display("");
        $display("  ★ 為什麼要用同步讀取？");
        $display("     FPGA 裡專用的 Block RAM 硬體上就是同步的。");
        $display("     寫成非同步，綜合工具只能改用 LUT 做 —— 很浪費。");
        $display("     一個 4Kb 的 BRAM 換成 LUT 要用掉幾百個邏輯單元。");
        $display("");
        $display("  ★ 代價：所有讀取都要「晚一拍」，設計時要記得算進去。");
        $display("");
        $finish;
    end
endmodule
