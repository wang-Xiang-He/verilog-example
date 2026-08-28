// ============================================================
//  期中考 第 1 題 —— 自動判分測試（不要改這個檔）
// ============================================================
`timescale 1ns / 1ps

module seg7_tb;

    reg  [3:0] bcd;
    wire [6:0] seg;
    integer i, pass = 0, fail = 0;
    reg  [6:0] golden;

    seg7 uut (.bcd(bcd), .seg(seg));

    // 標準答案表  {g,f,e,d,c,b,a}
    function [6:0] ref_seg;
        input [3:0] n;
        begin
            case (n)
                4'd0: ref_seg = 7'b0111111;
                4'd1: ref_seg = 7'b0000110;
                4'd2: ref_seg = 7'b1011011;
                4'd3: ref_seg = 7'b1001111;
                4'd4: ref_seg = 7'b1100110;
                4'd5: ref_seg = 7'b1101101;
                4'd6: ref_seg = 7'b1111101;
                4'd7: ref_seg = 7'b0000111;
                4'd8: ref_seg = 7'b1111111;
                4'd9: ref_seg = 7'b1101111;
                default: ref_seg = 7'b0000000;
            endcase
        end
    endfunction

    // 把 seg 畫成圖，方便你對照
    task draw;
        input [6:0] s;
        begin
            $display("        %s", s[0] ? " --- " : "     ");
            $display("       %s   %s", s[5] ? "|" : " ", s[1] ? "|" : " ");
            $display("        %s", s[6] ? " --- " : "     ");
            $display("       %s   %s", s[4] ? "|" : " ", s[2] ? "|" : " ");
            $display("        %s", s[3] ? " --- " : "     ");
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, seg7_tb);

        $display("");
        $display("  ============ 期中考 第 1 題：七段顯示解碼器 ============");
        $display("");
        $display("   bcd | 你的答案   標準答案   結果");
        $display("  -----+---------------------------------");

        for (i = 0; i < 16; i = i + 1) begin
            bcd = i[3:0];
            #10;
            golden = ref_seg(bcd);
            if (seg === golden) begin
                pass = pass + 1;
                $display("   %2d  | %b  %b   OK", i, seg, golden);
            end else begin
                fail = fail + 1;
                $display("   %2d  | %b  %b   <-- 錯", i, seg, golden);
            end
        end

        $display("");
        $display("  =================================================");
        $display("     得分：%0d / 16", pass);
        if (fail == 0) begin
            $display("     >>> 滿分通過！");
            $display("");
            $display("     顯示 8 的樣子：");
            bcd = 4'd8; #10;
            draw(seg);
        end else begin
            $display("     >>> 還有 %0d 個錯，繼續加油", fail);
        end
        $display("  =================================================");
        $display("");

        #10 $finish;
    end
endmodule
