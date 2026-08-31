`timescale 1ns / 1ps

module pnr_flow_tb;
    reg        clk, rst_n;
    reg  [7:0] a, b;
    reg  [2:0] op;
    wire [7:0] led, acc;
    wire       busy;

    integer i, err;
    reg [7:0] exp_acc;
    reg [7:0] alu_ref;

    pnr_demo uut (.clk(clk), .rst_n(rst_n), .a(a), .b(b), .op(op),
                  .led(led), .busy(busy), .acc(acc));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, pnr_flow_tb);
        clk = 0; rst_n = 0; a = 0; b = 0; op = 0; err = 0;
        exp_acc = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   佈局繞線流程的實驗對象：一個中等大小的設計");
        $display("  ============================================================");
        $display("");
        $display("   這個設計刻意包含三種資源，才看得出使用率報告的各欄位：");
        $display("     ALU     → 吃 LUT（組合邏輯）");
        $display("     累加器  → 吃 DFF + CARRY");
        $display("     計數器  → 吃 DFF + CARRY");

        $display("");
        $display("  ===== 功能驗證：隨機 500 拍 =====");
        $display("");
        //  ★ 一輪只走【一個】負緣。
        //    如果一輪走兩個負緣，同一組 a/b/op 會被累加兩次 ——
        //    這是寫累加器測試平台最常見的錯誤。
        for (i = 0; i < 500; i = i + 1) begin
            @(negedge clk);

            //  先檢查【上一輪】的期望值（這時剛好過了一個正緣）
            if (i > 0 && acc !== exp_acc) begin
                err = err + 1;
                if (err <= 3)
                    $display("   [X] 第 %0d 拍 acc=%0d 應該 %0d", i, acc, exp_acc);
            end

            a = $random; b = $random; op = $random;
            case (op)
                3'd0: alu_ref = a + b;
                3'd1: alu_ref = a - b;
                3'd2: alu_ref = a & b;
                3'd3: alu_ref = a | b;
                3'd4: alu_ref = a ^ b;
                3'd5: alu_ref = a << 1;
                3'd6: alu_ref = a >> 1;
                3'd7: alu_ref = ~a;
            endcase
            exp_acc = exp_acc + alu_ref;
        end
        @(negedge clk);
        if (acc !== exp_acc) err = err + 1;

        if (err == 0) $display("   ★ 500 拍全部正確");
        else          $display("   [X] 有 %0d 拍不符", err);

        $display("");
        $display("  ============================================================");
        $display("   ★ 現在跑三個 .bat，把佈局繞線拆開看：");
        $display("");
        $display("     01_pnr_flow.bat       逐步跑完流程，看每一步產生什麼");
        $display("     02_timing_report.bat  讀懂時序報告（★ 本週重點）");
        $display("     04_utilization.bat    資源使用率分析");
        $display("");
        $display("   本設計的實測結果（HX8K, seed=1）：");
        $display("     ICESTORM_LC   113 / 7680   （1%%）");
        $display("     SB_IO          38 / 206    （18%%）");
        $display("     SB_GB           1 / 8      （12%%）");
        $display("     nextpnr 最高時脈  258.26 MHz");
        $display("     icetime 估計      110.76 MHz");
        $display("");
        $display("   ⚠️ 兩個工具給的數字差很多 —— 02_timing_report.bat 會解釋為什麼。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
