`timescale 1ns / 1ps

module debounce_tb;
    reg clk = 0, rst, btn_raw;
    wire btn_clean, btn_pulse;
    integer pulses = 0;

    debounce #(.STABLE_CNT(8)) uut (
        .clk(clk), .rst(rst), .btn_raw(btn_raw),
        .btn_clean(btn_clean), .btn_pulse(btn_pulse)
    );

    always #5 clk = ~clk;
    always @(posedge clk) if (btn_pulse) pulses = pulses + 1;

    // 模擬一次「按下」：先抖動一陣子，再穩定
    task press;
        begin
            btn_raw = 1; #12;
            btn_raw = 0; #8;
            btn_raw = 1; #6;
            btn_raw = 0; #14;
            btn_raw = 1; #9;
            btn_raw = 0; #7;
            btn_raw = 1;               // 終於穩定
            #300;
        end
    endtask

    task release_btn;
        begin
            btn_raw = 0; #11;
            btn_raw = 1; #7;
            btn_raw = 0; #13;
            btn_raw = 1; #5;
            btn_raw = 0;               // 穩定放開
            #300;
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, debounce_tb);

        $display("");
        $display("  模擬按一下按鍵 —— 實體按鍵接觸瞬間會彈跳很多次");
        $display("");

        rst = 1; btn_raw = 0;
        #40 rst = 0;
        #40;

        $display("   第 1 次按下（含彈跳）...");
        press;
        $display("      btn_clean = %b   累計脈衝數 = %0d", btn_clean, pulses);

        $display("   放開（含彈跳）...");
        release_btn;
        $display("      btn_clean = %b   累計脈衝數 = %0d", btn_clean, pulses);

        $display("   第 2 次按下（含彈跳）...");
        press;
        $display("      btn_clean = %b   累計脈衝數 = %0d", btn_clean, pulses);

        release_btn;

        $display("");
        if (pulses == 2)
            $display("  >>> 正確！按了 2 次，只產生 2 個脈衝");
        else
            $display("  >>> 錯誤！按了 2 次卻產生 %0d 個脈衝", pulses);
        $display("");
        $display("  ★ 看波形對照 btn_raw 和 btn_clean：");
        $display("    btn_raw   一開始像鋸齒一樣亂抖");
        $display("    btn_clean 乾乾淨淨只有一次高低");
        $display("    btn_pulse 只在按下的那一拍出現一個窄脈衝");
        $display("");
        $display("  ★ 沒有去彈跳會怎樣？按一下按鍵，計數器可能跳 5、6 下");
        $display("");
        $finish;
    end
endmodule
