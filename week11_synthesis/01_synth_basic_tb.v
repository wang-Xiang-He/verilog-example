`timescale 1ns / 1ps

module synth_basic_tb;
    reg  [3:0] a4, b4;
    reg        cin;
    wire [3:0] sum4;
    wire       cout4;

    reg        clk, rst_n, en;
    wire [3:0] count;

    reg  [7:0] a8, b8;
    wire [15:0] p;
    wire [8:0]  s;

    integer i, err;

    adder4   u_add4  (.a(a4), .b(b4), .cin(cin), .sum(sum4), .cout(cout4));
    counter4 u_cnt   (.clk(clk), .rst_n(rst_n), .en(en), .count(count));
    mult8    u_mult  (.a(a8), .b(b8), .p(p));
    add8     u_add8  (.a(a8), .b(b8), .s(s));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, synth_basic_tb);
        clk = 0; rst_n = 0; en = 0;
        a4 = 0; b4 = 0; cin = 0; a8 = 0; b8 = 0; err = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   先確認功能都對，再去看綜合報告");
        $display("  ============================================================");

        //  ---- adder4 窮舉 ----
        $display("");
        $display("  ===== adder4：窮舉 4x16x16 = 512 組 =====");
        for (i = 0; i < 512; i = i + 1) begin
            {cin, a4, b4} = i[8:0];
            #1;
            if ({cout4, sum4} !== (a4 + b4 + cin)) err = err + 1;
        end
        if (err == 0) $display("   ★ 全部正確");
        else          $display("   [X] %0d 組錯", err);

        //  ---- counter4 ----
        $display("");
        $display("  ===== counter4：數 18 拍看它繞圈 =====");
        $display("");
        en = 1;
        $write("   ");
        for (i = 0; i < 18; i = i + 1) begin
            @(negedge clk);
            $write("%0d ", count);
        end
        $display("");
        $display("   ★ 數到 15 就繞回 0 —— 4 位元只能表示 0~15");

        //  ---- mult8 / add8 ----
        $display("");
        $display("  ===== mult8 / add8：隨機 1000 組 =====");
        err = 0;
        for (i = 0; i < 1000; i = i + 1) begin
            a8 = $random; b8 = $random; #1;
            if (p !== a8 * b8)  err = err + 1;
            if (s !== a8 + b8)  err = err + 1;
        end
        if (err == 0) $display("   ★ 全部正確");
        else          $display("   [X] %0d 組錯", err);

        $display("");
        $display("  ============================================================");
        $display("   功能都對了。現在跑綜合，看看它們各要多少資源：");
        $display("");
        $display("       yosys -s 01_synth_basic.ys");
        $display("");
        $display("   結果會寫進 report.txt。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
