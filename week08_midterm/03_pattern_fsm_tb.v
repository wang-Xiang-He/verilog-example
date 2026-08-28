// ============================================================
//  期中考 第 3 題 —— 自動判分測試（不要改這個檔）
// ============================================================
`timescale 1ns / 1ps

module pattern_fsm_tb;

    reg clk = 0, rst, key_valid;
    reg  [1:0] key;
    wire unlock;
    wire [1:0] state_out;

    integer pass = 0, fail = 0;
    integer unlock_count = 0;

    pattern_fsm uut (.clk(clk), .rst(rst), .key(key), .key_valid(key_valid),
                     .unlock(unlock), .state_out(state_out));

    always #5 clk = ~clk;
    always @(posedge clk) if (unlock) unlock_count = unlock_count + 1;

    // 按一個鍵
    task press(input [1:0] k);
        begin
            key = k; key_valid = 1;
            @(posedge clk); #1;
            key_valid = 0;
        end
    endtask

    // 檢查目前 unlock 狀態是否符合預期
    task expect_unlock(input exp);
        begin
            if (unlock === exp) pass = pass + 1;
            else begin
                fail = fail + 1;
                $display("   [X] t=%0t  unlock=%b，應該是 %b", $time, unlock, exp);
            end
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, pattern_fsm_tb);

        $display("");
        $display("  ========== 期中考 第 3 題：密碼鎖 ==========");
        $display("   正確密碼：1 -> 2 -> 3 -> 0");
        $display("");

        rst = 1; key = 0; key_valid = 0;
        @(posedge clk); @(posedge clk); #1 rst = 0;

        $display("   測試 1：正確輸入 1,2,3,0");
        press(2'd1); expect_unlock(0);
        press(2'd2); expect_unlock(0);
        press(2'd3); expect_unlock(0);
        press(2'd0); expect_unlock(1);        // ★ 這裡要開鎖
        @(posedge clk); #1; expect_unlock(0); // 只拉高一拍

        $display("   測試 2：錯誤輸入 1,2,2,0（第三碼錯）");
        press(2'd1); expect_unlock(0);
        press(2'd2); expect_unlock(0);
        press(2'd2); expect_unlock(0);
        press(2'd0); expect_unlock(0);
        @(posedge clk); #1;

        $display("   測試 3：中途按錯但立刻重來 1,3,1,2,3,0");
        press(2'd1); expect_unlock(0);
        press(2'd3); expect_unlock(0);        // 錯，回起點
        press(2'd1); expect_unlock(0);        // 重新開始
        press(2'd2); expect_unlock(0);
        press(2'd3); expect_unlock(0);
        press(2'd0); expect_unlock(1);        // ★ 要開鎖
        @(posedge clk); #1;

        $display("   測試 4：key_valid=0 的時候不能算數");
        press(2'd1);
        key = 2'd2; key_valid = 0;
        @(posedge clk); #1;                   // 這拍不算
        @(posedge clk); #1;
        press(2'd2);
        press(2'd3);
        press(2'd0); expect_unlock(1);        // ★ 要開鎖
        @(posedge clk); #1;

        $display("   測試 5：rst 中途重置");
        press(2'd1);
        press(2'd2);
        rst = 1; @(posedge clk); #1; rst = 0;
        press(2'd3);
        press(2'd0); expect_unlock(0);        // 被重置過，不該開

        $display("");
        $display("  ============================================");
        $display("     得分：%0d / %0d", pass, pass + fail);
        $display("     總共開鎖 %0d 次（應該是 3 次）", unlock_count);
        if (fail == 0 && unlock_count == 3)
            $display("     >>> 全部通過！");
        else
            $display("     >>> 還有問題，再檢查一次");
        $display("  ============================================");
        $display("");
        $finish;
    end
endmodule
