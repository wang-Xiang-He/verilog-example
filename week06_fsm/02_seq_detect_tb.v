`timescale 1ns / 1ps

module seq_detect_tb;
    reg clk = 0, rst, din;
    wire found_moore, found_mealy;
    wire [2:0] state_out;
    integer i;

    // 測試序列：含兩次 1011（第二次跟第一次重疊）
    //            0 1 0 1 1 0 1 1 0 1 1 1 0
    reg [0:12] pattern = 13'b0101101101110;

    seq_detect uut (.clk(clk), .rst(rst), .din(din),
                    .found_moore(found_moore), .found_mealy(found_mealy),
                    .state_out(state_out));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, seq_detect_tb);

        $display("");
        $display("   偵測目標：1 0 1 1");
        $display("");
        $display("   拍  din  狀態   Mealy  Moore");
        $display("  --------------------------------");

        rst = 1; din = 0;
        @(posedge clk); @(posedge clk); #1 rst = 0;

        for (i = 0; i < 13; i = i + 1) begin
            din = pattern[i];
            #1;                              // 讓 Mealy 的組合輸出穩定
            @(posedge clk); #1;
            if (found_moore)
                $display("   %2d   %b    S%0d      %b      %b   <<< 找到 1011 !",
                         i, pattern[i], state_out, found_mealy, found_moore);
            else
                $display("   %2d   %b    S%0d      %b      %b",
                         i, pattern[i], state_out, found_mealy, found_moore);
        end

        $display("");
        $display("  ★★ Moore vs Mealy：");
        $display("     Mealy 在「輸入的那一拍」就拉高 —— 快，但跟著輸入抖動");
        $display("     Moore 在「下一拍」才拉高     —— 慢一拍，但輸出乾淨穩定");
        $display("");
        $display("     業界大多用 Moore（乾淨的輸出比較好接下一級）");
        $display("");
        $finish;
    end
endmodule
