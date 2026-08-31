`timescale 1ns / 1ps

module stack_queue_tb;
    reg        clk, rst_n, push, pop, wr, rd;
    reg  [7:0] din;
    wire [7:0] s_top, q_front;
    wire       s_empty, s_full, q_empty, q_full;
    wire [3:0] s_count, q_count;

    integer i, err;
    reg [7:0] got [0:7];

    stack_queue uut (.clk(clk), .rst_n(rst_n),
                     .push(push), .pop(pop), .wr(wr), .rd(rd), .din(din),
                     .s_top(s_top), .q_front(q_front),
                     .s_empty(s_empty), .s_full(s_full),
                     .q_empty(q_empty), .q_full(q_full),
                     .s_count(s_count), .q_count(q_count));

    always #5 clk = ~clk;

    //  一律在負緣驅動，避開和 posedge always 的競爭
    task do_push; input [7:0] d; begin
        @(negedge clk); din = d; push = 1; pop = 0;
        @(negedge clk); push = 0;
    end endtask

    task do_pop; begin
        @(negedge clk); push = 0; pop = 1;
        @(negedge clk); pop = 0;
    end endtask

    task do_wr; input [7:0] d; begin
        @(negedge clk); din = d; wr = 1; rd = 0;
        @(negedge clk); wr = 0;
    end endtask

    task do_rd; begin
        @(negedge clk); wr = 0; rd = 1;
        @(negedge clk); rd = 0;
    end endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, stack_queue_tb);
        clk = 0; rst_n = 0; push = 0; pop = 0; wr = 0; rd = 0; din = 0;
        err = 0;
        #12 rst_n = 1;

        // ============================================================
        $display("");
        $display("  ===== 一、堆疊 Stack：後進先出 LIFO（課本 12.3.1）=====");
        $display("");
        $display("   依序 push 進 A1 A2 A3 A4 A5");
        $display("");
        $display("   動作      | sp | top | empty full");
        $display("   ----------+----+-----+------------");
        for (i = 1; i <= 5; i = i + 1) begin
            do_push(8'hA0 + i[7:0]);
            $display("   push %h  | %0d  | %h  |   %0d    %0d",
                     8'hA0 + i[7:0], s_count, s_top, s_empty, s_full);
        end

        $display("");
        $display("   ---- 開始 pop，看它是不是【倒著出來】----");
        $display("");
        $display("   動作      | sp | top | 這次取出");
        $display("   ----------+----+-----+----------");
        for (i = 0; i < 5; i = i + 1) begin
            got[i] = s_top;             // pop 之前先把 top 記下來
            do_pop;
            $display("   pop       | %0d  | %h  |   %h", s_count, s_top, got[i]);
        end

        $display("");
        $display("   進去順序：A1 A2 A3 A4 A5");
        $display("   出來順序：%h %h %h %h %h", got[0], got[1], got[2], got[3], got[4]);
        if (got[0] === 8'hA5 && got[1] === 8'hA4 && got[2] === 8'hA3 &&
            got[3] === 8'hA2 && got[4] === 8'hA1)
            $display("   ★ 完全倒過來 —— 這就是 LIFO");
        else begin
            $display("   [X] 順序不對");
            err = err + 1;
        end

        // ============================================================
        $display("");
        $display("  ===== 二、堆疊的邊界：空的時候 pop、滿的時候 push =====");
        $display("");
        $display("   現在 empty=%0d，再 pop 一次看看 ...", s_empty);
        do_pop;
        $display("   pop 之後 sp=%0d（沒有變成負的，被 empty 擋掉了）", s_count);
        if (s_count !== 0) err = err + 1;

        $display("");
        $display("   連續 push 10 次（但只有 8 格）...");
        for (i = 0; i < 10; i = i + 1) do_push(8'hB0 + i[7:0]);
        $display("   push 之後 sp=%0d  full=%0d（滿了就不再收，被 full 擋掉）",
                 s_count, s_full);
        if (s_count !== 8) err = err + 1;

        // ============================================================
        $display("");
        $display("  ===== 三、佇列 Queue：先進先出 FIFO（課本 12.3.2）=====");
        $display("");
        $display("   依序寫進 C1 C2 C3 C4 C5");
        $display("");
        $display("   動作      | count | front | empty full");
        $display("   ----------+-------+-------+------------");
        for (i = 1; i <= 5; i = i + 1) begin
            do_wr(8'hC0 + i[7:0]);
            $display("   write %h  |   %0d   |  %h   |   %0d    %0d",
                     8'hC0 + i[7:0], q_count, q_front, q_empty, q_full);
        end

        $display("");
        $display("   ---- 開始讀，看它是不是【照原順序出來】----");
        $display("");
        $display("   動作      | count | front | 這次取出");
        $display("   ----------+-------+-------+----------");
        for (i = 0; i < 5; i = i + 1) begin
            got[i] = q_front;
            do_rd;
            $display("   read      |   %0d   |  %h   |   %h", q_count, q_front, got[i]);
        end

        $display("");
        $display("   進去順序：C1 C2 C3 C4 C5");
        $display("   出來順序：%h %h %h %h %h", got[0], got[1], got[2], got[3], got[4]);
        if (got[0] === 8'hC1 && got[1] === 8'hC2 && got[2] === 8'hC3 &&
            got[3] === 8'hC4 && got[4] === 8'hC5)
            $display("   ★ 順序完全保持 —— 這就是 FIFO");
        else begin
            $display("   [X] 順序不對");
            err = err + 1;
        end

        // ============================================================
        $display("");
        $display("  ===== 四、★ 佇列可以同一拍又讀又寫 =====");
        $display("");
        do_wr(8'hD1); do_wr(8'hD2); do_wr(8'hD3);
        $display("   先塞三個：count=%0d  front=%h", q_count, q_front);
        @(negedge clk); wr = 1; rd = 1; din = 8'hD4;
        @(negedge clk); wr = 0; rd = 0;
        $display("   同一拍 wr=1 且 rd=1 之後：count=%0d  front=%h", q_count, q_front);
        $display("   ★ 進一個、出一個，count 沒變 —— 這是佇列的重要特性。");
        $display("     堆疊做不到這件事（只有一根指標，不可能同時往兩邊動）。");

        // ============================================================
        $display("");
        $display("  ------------------------------------------------------------");
        if (err == 0) $display("   ★ 全部檢查通過，0 個錯");
        else          $display("   [X] 有 %0d 項不符", err);
        $display("");
        $display("   總結（考試會考的對照）：");
        $display("");
        $display("              堆疊 Stack        佇列 Queue");
        $display("     指標      1 根 (sp)         2 根 (wp / rp)");
        $display("     順序      後進先出 LIFO     先進先出 FIFO");
        $display("     同拍讀寫  做不到            ★ 可以");
        $display("     典型用途  函式呼叫、括號配對  跨模組緩衝、鮑率不同的介面");
        $display("");
        $display("   ★ 兩者的硬體【都只是一塊 RAM + 幾個計數器】，");
        $display("     差別完全在指標怎麼動。");
        $display("     本週的 04_fifo 就是這個 queue 加上完整空滿旗標的版本。");
        $display("");
        #20 $finish;
    end
endmodule
