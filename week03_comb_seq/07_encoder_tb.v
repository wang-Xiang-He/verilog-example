`timescale 1ns / 1ps

module encoder_tb;
    reg  [7:0] din;
    wire [2:0] code_plain, code_pri, code_casez;
    wire       valid;
    integer i, err;

    encoder uut (.din(din), .code_plain(code_plain), .code_pri(code_pri),
                 .code_casez(code_casez), .valid(valid));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, encoder_tb);
        err = 0;

        $display("");
        $display("  ===== 一、只有一位是 1（三種寫法應該完全一致）=====");
        $display("");
        $display("      din     | 普通  優先  casez | valid");
        $display("   -----------+-------------------+-------");
        for (i = 0; i < 8; i = i + 1) begin
            din = 8'b1 << i; #10;
            $display("   %b |  %0d     %0d     %0d   |   %0d",
                     din, code_plain, code_pri, code_casez, valid);
            if (code_pri !== code_casez) err = err + 1;
        end

        $display("");
        $display("  ===== 二、★ 同時有多位是 1 =====");
        $display("");
        $display("      din     | 普通  優先  casez | 說明");
        $display("   -----------+-------------------+-------------------------");
        din = 8'b0010_0100; #10;
        $display("   %b |  %b   %0d     %0d   | 普通的認不出來，優先的挑 5",
                 din, code_plain, code_pri, code_casez);
        din = 8'b1000_0001; #10;
        $display("   %b |  %b   %0d     %0d   | bit7 和 bit0 同時來，挑 7",
                 din, code_plain, code_pri, code_casez);
        din = 8'b1111_1111; #10;
        $display("   %b |  %b   %0d     %0d   | 全部都是 1，還是挑 7",
                 din, code_plain, code_pri, code_casez);

        $display("");
        $display("  ===== 三、全 0 =====");
        din = 8'b0000_0000; #10;
        $display("   %b |  %b   %0d     %0d   | valid=%0d ← 這時 code 不能信",
                 din, code_plain, code_pri, code_casez, valid);

        $display("");
        $display("  ------------------------------------------------------------");
        if (err == 0)
            $display("   ★ if-else 版和 casez 版結果完全一致（0 個不符）");
        else
            $display("   [X] 兩種寫法有 %0d 處不一致", err);
        $display("");
        $display("   要記住的三件事：");
        $display("     1. 普通編碼器只能處理 one-hot，多位同時是 1 就吐 x");
        $display("     2. 優先編碼器用 if-else 或 casez，天生帶優先權");
        $display("     3. ★ 一定要有 valid，否則分不出「編碼 0」和「什麼都沒有」");
        $display("");
        #20 $finish;
    end
endmodule
