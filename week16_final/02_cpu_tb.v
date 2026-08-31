`timescale 1ns / 1ps

// ============================================================
//  期末專題 第 2 題 —— 自動判分測試平台
//  配分：LDA 20 + ADD 25 + STA 25 + JMP 20 + 綜合程式 10 = 100 分
// ============================================================
module cpu_tb;
    reg        clk, rst_n;
    reg        load_en;
    reg  [5:0] load_addr;
    reg  [7:0] load_data;
    reg  [5:0] peek_addr;

    wire [5:0] pc_out;
    wire [7:0] acc_out, ir_out, peek_data;
    wire [1:0] state_out;
    wire       halted;

    integer i, score, guard;
    reg [7:0] m50, m51;

    cpu uut (.clk(clk), .rst_n(rst_n),
             .pc_out(pc_out), .acc_out(acc_out), .ir_out(ir_out),
             .state_out(state_out), .halted(halted),
             .load_en(load_en), .load_addr(load_addr), .load_data(load_data),
             .peek_addr(peek_addr), .peek_data(peek_data));

    always #5 clk = ~clk;

    //  ---- 指令組譯小工具 ----
    function [7:0] LDA; input [5:0] a; LDA = {2'b00, a}; endfunction
    function [7:0] ADD; input [5:0] a; ADD = {2'b01, a}; endfunction
    function [7:0] STA; input [5:0] a; STA = {2'b10, a}; endfunction
    function [7:0] JMP; input [5:0] a; JMP = {2'b11, a}; endfunction

    //  ---- 把一個位元組寫進記憶體 ----
    task poke;
        input [5:0] a;
        input [7:0] d;
        begin
            @(negedge clk);
            load_en = 1; load_addr = a; load_data = d;
            @(negedge clk);
            load_en = 0;
        end
    endtask

    //  ---- 讓 CPU 跑到停住（或逾時）----
    task run_until_halt;
        input integer max_cycles;
        begin
            guard = 0;
            while (!halted && guard < max_cycles) begin
                @(posedge clk);
                guard = guard + 1;
            end
        end
    endtask

    //  ---- 讀記憶體 ----
    //  ⚠️ 這裡一定要用 task 不能用 function：
    //     Verilog 的 function【不能有延遲】(#1)，
    //     而我們需要等 peek_data 這條組合邏輯穩定下來。
    reg [7:0] mval;
    task read_mem;
        input [5:0] a;
        begin
            peek_addr = a;
            #1;
            mval = peek_data;
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, cpu_tb);
        clk = 0; rst_n = 0; load_en = 0;
        load_addr = 0; load_data = 0; peek_addr = 0;
        score = 0;

        $display("");
        $display("  ============================================================");
        $display("   期末專題 第 2 題：簡易 8-bit CPU");
        $display("  ============================================================");

        // ========================================================
        //  測試 1：LDA（20 分）
        //  程式： LDA 32   →   JMP 1（跳回自己，停住）
        //  資料： mem[32] = 0x5A
        // ========================================================
        $display("");
        $display("  ===== 測試 1：LDA（20 分）=====");
        $display("");
        $display("     位址 0: LDA 32      ACC <- mem[32]");
        $display("     位址 1: JMP 1       停住");
        $display("     mem[32] = 0x5A");
        $display("");
        rst_n = 0;
        poke(6'd0,  LDA(6'd32));
        poke(6'd1,  JMP(6'd1));
        poke(6'd32, 8'h5A);
        @(negedge clk); rst_n = 1;
        run_until_halt(200);

        if (acc_out === 8'h5A) begin
            score = score + 20;
            $display("   [O] ACC = 0x%h                                (20/20)", acc_out);
        end else
            $display("   [X] ACC = 0x%h，應該是 0x5A                   (0/20)", acc_out);

        // ========================================================
        //  測試 2：ADD（25 分）
        //  LDA 32 ; ADD 33 ; ADD 34 ; JMP 3
        // ========================================================
        $display("");
        $display("  ===== 測試 2：ADD（25 分）=====");
        $display("");
        $display("     LDA 32 ; ADD 33 ; ADD 34 ; JMP 3");
        $display("     mem[32]=10, mem[33]=20, mem[34]=30  → 期望 ACC=60");
        $display("");
        rst_n = 0;
        poke(6'd0,  LDA(6'd32));
        poke(6'd1,  ADD(6'd33));
        poke(6'd2,  ADD(6'd34));
        poke(6'd3,  JMP(6'd3));
        poke(6'd32, 8'd10);
        poke(6'd33, 8'd20);
        poke(6'd34, 8'd30);
        @(negedge clk); rst_n = 1;
        run_until_halt(300);

        if (acc_out === 8'd60) begin
            score = score + 25;
            $display("   [O] ACC = %0d                                  (25/25)", acc_out);
        end else
            $display("   [X] ACC = %0d，應該是 60                       (0/25)", acc_out);

        // ========================================================
        //  測試 3：STA（25 分）
        //  LDA 32 ; ADD 33 ; STA 40 ; JMP 3
        // ========================================================
        $display("");
        $display("  ===== 測試 3：STA（25 分）=====");
        $display("");
        $display("     LDA 32 ; ADD 33 ; STA 40 ; JMP 3");
        $display("     mem[32]=7, mem[33]=5  → 期望 mem[40]=12");
        $display("");
        rst_n = 0;
        poke(6'd0,  LDA(6'd32));
        poke(6'd1,  ADD(6'd33));
        poke(6'd2,  STA(6'd40));
        poke(6'd3,  JMP(6'd3));
        poke(6'd32, 8'd7);
        poke(6'd33, 8'd5);
        poke(6'd40, 8'd0);
        @(negedge clk); rst_n = 1;
        run_until_halt(300);

        read_mem(6'd40);
        if (mval === 8'd12) begin
            score = score + 25;
            $display("   [O] mem[40] = %0d                              (25/25)", mval);
        end else
            $display("   [X] mem[40] = %0d，應該是 12                   (0/25)", mval);

        // ========================================================
        //  測試 4：JMP（20 分）
        //  用 JMP 跳過一段指令，證明它真的會跳
        //
        //     0: LDA 32     ACC = 1
        //     1: JMP 4      跳到 4，跳過位址 2、3
        //     2: ADD 33     (不應該執行)
        //     3: ADD 33     (不應該執行)
        //     4: ADD 34     ACC = 1 + 100 = 101
        //     5: JMP 5      停住
        // ========================================================
        $display("");
        $display("  ===== 測試 4：JMP（20 分）=====");
        $display("");
        $display("     0: LDA 32     1: JMP 4     2: ADD 33 (跳過)");
        $display("     3: ADD 33     4: ADD 34    5: JMP 5");
        $display("     mem[32]=1, mem[33]=50, mem[34]=100");
        $display("     ★ 跳對 → ACC=101；沒跳 → ACC=201");
        $display("");
        rst_n = 0;
        poke(6'd0,  LDA(6'd32));
        poke(6'd1,  JMP(6'd4));
        poke(6'd2,  ADD(6'd33));
        poke(6'd3,  ADD(6'd33));
        poke(6'd4,  ADD(6'd34));
        poke(6'd5,  JMP(6'd5));
        poke(6'd32, 8'd1);
        poke(6'd33, 8'd50);
        poke(6'd34, 8'd100);
        @(negedge clk); rst_n = 1;
        run_until_halt(400);

        if (acc_out === 8'd101) begin
            score = score + 20;
            $display("   [O] ACC = %0d，JMP 正確跳過了兩行              (20/20)", acc_out);
        end else if (acc_out === 8'd201)
            $display("   [X] ACC = %0d —— JMP 沒有跳，把 2、3 也執行了  (0/20)", acc_out);
        else
            $display("   [X] ACC = %0d，應該是 101                      (0/20)", acc_out);

        // ========================================================
        //  測試 5：綜合程式（10 分）
        //  算 (5+6+7+8) 存到 mem[50]，再把它加倍存到 mem[51]
        // ========================================================
        $display("");
        $display("  ===== 測試 5：綜合程式（10 分）=====");
        $display("");
        $display("     算 5+6+7+8=26 存到 mem[50]，");
        $display("     再讀回來加自己一次 = 52 存到 mem[51]");
        $display("");
        rst_n = 0;
        poke(6'd0,  LDA(6'd32));      // ACC = 5
        poke(6'd1,  ADD(6'd33));      // ACC = 11
        poke(6'd2,  ADD(6'd34));      // ACC = 18
        poke(6'd3,  ADD(6'd35));      // ACC = 26
        poke(6'd4,  STA(6'd50));      // mem[50] = 26
        poke(6'd5,  ADD(6'd50));      // ACC = 26+26 = 52
        poke(6'd6,  STA(6'd51));      // mem[51] = 52
        poke(6'd7,  JMP(6'd7));
        poke(6'd32, 8'd5);
        poke(6'd33, 8'd6);
        poke(6'd34, 8'd7);
        poke(6'd35, 8'd8);
        poke(6'd50, 8'd0);
        poke(6'd51, 8'd0);
        @(negedge clk); rst_n = 1;
        run_until_halt(600);

        read_mem(6'd50); m50 = mval;
        read_mem(6'd51); m51 = mval;
        if (m50 === 8'd26 && m51 === 8'd52) begin
            score = score + 10;
            $display("   [O] mem[50]=%0d  mem[51]=%0d                   (10/10)", m50, m51);
        end else
            $display("   [X] mem[50]=%0d mem[51]=%0d，應該是 26 和 52   (0/10)", m50, m51);

        // ========================================================
        $display("");
        $display("  ============================================================");
        $display("     總分  %0d / 100", score);
        $display("");
        if (score == 100) begin
            $display("     ★★★ 滿分！你做出了一台【真的 CPU】。");
            $display("");
            $display("     它有取指令、解碼、執行三個階段，有程式計數器、");
            $display("     累加器、指令暫存器，會做算術也會跳躍。");
            $display("     Intel 4004（1971 年第一顆商用 CPU）也就是這個");
            $display("     架構再複雜一點而已。");
        end else if (score >= 70)
            $display("     ★ 主要功能都對了，剩下的再檢查一次。");
        else if (score >= 20)
            $display("     >>> 架構有了。最常錯的是 JMP —— FETCH 時 pc 已經 +1，");
        else
            $display("     >>> 先把 FETCH/DECODE/EXECUTE 三個狀態轉起來。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end

    initial begin
        #500_000;
        $display("");
        $display("   [!] 模擬逾時 —— 狀態機可能卡住了，或 halted 永遠不會拉起來");
        $finish;
    end
endmodule
