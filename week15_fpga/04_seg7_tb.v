`timescale 1ns / 1ps

module seg7_tb;
    reg        clk;
    wire [7:0] seg;
    wire [3:0] digit;
    wire       tick;

    integer i, which;

    //  參數調小：時脈 400Hz、掃描 100Hz → 每 4 拍換一位
    seg7_top #(.CLK_HZ(400), .SCAN_HZ(100)) uut (
        .clk(clk), .seg(seg), .digit(digit), .tick(tick));

    always #5 clk = ~clk;

    //  把七段圖案翻譯回數字，用來驗證
    function [7:0] decode;
        input [6:0] p;
        begin
            case (p)
                7'b0111111: decode = 0;
                7'b0000110: decode = 1;
                7'b1011011: decode = 2;
                7'b1001111: decode = 3;
                7'b1100110: decode = 4;
                7'b1101101: decode = 5;
                7'b1111101: decode = 6;
                7'b0000111: decode = 7;
                7'b1111111: decode = 8;
                7'b1101111: decode = 9;
                default:    decode = 8'hFF;
            endcase
        end
    endfunction

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, seg7_tb);
        clk = 0;

        $display("");
        $display("  ============================================================");
        $display("   四位數七段顯示：一次點一位，靠視覺暫留騙過眼睛");
        $display("  ============================================================");
        $display("");
        $display("   問題：四位數要 4x8 = 32 支腳，板子只有 12 支。");
        $display("   解法：一次只點亮一位，快速輪流掃。");
        $display("");

        //  先讓 value 走到一個好認的數字
        force uut.value = 14'd1234;
        repeat (4) @(negedge clk);

        $display("   顯示的數字 = 1234");
        $display("");
        $display("   拍  | digit  | seg      | 這一輪點亮哪位 | 顯示什麼");
        $display("   ----+--------+----------+----------------+----------");

        for (i = 0; i < 20; i = i + 1) begin
            @(negedge clk);
            which = -1;
            case (digit)
                4'b1110: which = 0;
                4'b1101: which = 1;
                4'b1011: which = 2;
                4'b0111: which = 3;
            endcase
            if (i % 2 == 0)
                $display("   %3d | %b   | %b |     第 %0d 位     |    %0d",
                         i, digit, seg, which, decode(seg[6:0]));
        end

        release uut.value;

        $display("");
        $display("   ★ digit 那一欄永遠【只有一個 0】—— 一次只點亮一位。");
        $display("     seg 那一欄跟著換成對應位數的字型。");
        $display("");
        $display("   把掃描速度放慢到 1Hz，你會看到四個位數【一個一個亮】；");
        $display("   放快到 1000Hz，人眼就以為四位數同時亮著。");

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   ★★ 掃描頻率怎麼選？");
        $display("");
        $display("     太慢（< 60Hz x 位數）→ 看得到閃爍");
        $display("     太快（> 幾十 kHz）   → 每位亮的時間太短，整體變暗");
        $display("                            而且 LED 的上升時間跟不上");
        $display("");
        $display("     常用值：每位 100~250Hz，四位數就是 400~1000Hz");
        $display("");
        $display("   ⚠️ 本範例用了除法和取餘數把二進位拆成十進位：");
        $display("        d0 = value %% 10;");
        $display("        d1 = (value / 10) %% 10;");
        $display("     這【會合成出很大的電路】（第 11 週學過乘除很貴）。");
        $display("     實務上會改用【雙重高低法 Double Dabble】演算法，");
        $display("     只用位移和加法就能做二進位轉 BCD。");
        $display("     → 這是本週練習題 3。");
        $display("");
        $display("   ⚠️ 共陽極 vs 共陰極：");
        $display("     本範例假設【共陰極】（1 = 亮）。");
        $display("     如果你的顯示器是共陽極，seg 要整個反相，");
        $display("     否則會變成負片效果（該亮的不亮、該暗的全亮）。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
