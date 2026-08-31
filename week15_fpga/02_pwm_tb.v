`timescale 1ns / 1ps

module pwm_tb;
    reg  clk;
    wire pwm_out, pwm_out2, tick;

    integer i, j, hi, lo;

    //  PWM_BITS 調小成 4（16 階），模擬才跑得完
    pwm #(.CLK_HZ(4096), .PWM_BITS(4), .BREATH_HZ(1)) uut (
        .clk(clk), .pwm_out(pwm_out), .pwm_out2(pwm_out2), .tick(tick));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, pwm_tb);
        clk = 0;

        $display("");
        $display("  ============================================================");
        $display("   PWM 呼吸燈：用開關的比例做出「亮度」");
        $display("  ============================================================");
        $display("");
        $display("   模擬參數：PWM_BITS=4（16 階），CLK_HZ=4096");

        // ============================================================
        $display("");
        $display("  ===== 一、固定 25%% 那條（pwm_out2）=====");
        $display("");
        hi = 0; lo = 0;
        for (i = 0; i < 160; i = i + 1) begin
            @(negedge clk);
            if (pwm_out2) hi = hi + 1; else lo = lo + 1;
        end
        $display("   量 160 拍：高 %0d 拍、低 %0d 拍 → 工作週期 %0d%%",
                 hi, lo, (hi*100)/(hi+lo));
        $display("   ★ 設定是 2^(4-2)/2^4 = 4/16 = 25%%，量到 %0d%% 正確",
                 (hi*100)/(hi+lo));

        // ============================================================
        $display("");
        $display("  ===== 二、★ 呼吸燈：duty 慢慢變大變小 =====");
        $display("");
        $display("   duty | 工作週期 | 亮度示意");
        $display("   -----+----------+---------------------");

        for (j = 0; j < 12; j = j + 1) begin
            //  等 duty 換一階
            @(posedge tick);
            @(negedge clk);
            hi = 0; lo = 0;
            for (i = 0; i < 16; i = i + 1) begin
                @(negedge clk);
                if (pwm_out) hi = hi + 1; else lo = lo + 1;
            end
            $write("   %4d |   %3d%%   | ", uut.duty, (hi*100)/16);
            for (i = 0; i < hi; i = i + 1) $write("#");
            for (i = hi; i < 16; i = i + 1) $write(".");
            $display("");
        end

        $display("");
        $display("   ★ 上面那一欄的 # 越來越長 —— 那就是「越來越亮」。");
        $display("     波形上看 pwm_out，高電位的寬度會慢慢變寬又變窄。");

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   ★★ PWM 的兩個關鍵數字：");
        $display("");
        $display("     解析度 = 2^PWM_BITS 階");
        $display("       8 位元 = 256 階亮度，肉眼看已經很平滑");
        $display("");
        $display("     PWM 頻率 = CLK_HZ / 2^PWM_BITS");
        $display("       12MHz / 256 = 46875 Hz");
        $display("       ★ 一定要遠高於 60Hz，否則肉眼會看到閃爍");
        $display("");
        $display("     ⚠️ 這兩個是【互相拉扯】的：");
        $display("        位元數越多 → 亮度越細膩，但 PWM 頻率越低");
        $display("        位元數太多（例如 16 位元）→ 12M/65536 = 183Hz，");
        $display("        快速移動眼睛時會看到殘影。");
        $display("");
        $display("   ★ PWM 不只能控 LED —— 馬達轉速、加熱器功率、");
        $display("     甚至簡易的音訊輸出，用的都是同一顆電路。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
