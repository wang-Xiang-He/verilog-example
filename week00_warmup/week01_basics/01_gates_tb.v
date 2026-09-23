// ============================================================
//  第 1 週 範例 1 的測試平台
//  重點：窮舉所有輸入組合，印出真值表
// ============================================================
`timescale 1ns / 1ps

module gates_tb;

    reg  a, b;                                  // 我要「產生」的 → reg
    wire y_and, y_or, y_not_a, y_xor;           // 我要「接收」的 → wire

    gates uut (
        .a(a), .b(b),
        .y_and(y_and), .y_or(y_or),
        .y_not_a(y_not_a), .y_xor(y_xor)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, gates_tb);

        $display("");
        $display("   a  b  |  AND   OR   NOT_a  XOR");
        $display("  -------+------------------------");

        a = 0; b = 0; #10 show;
        a = 0; b = 1; #10 show;
        a = 1; b = 0; #10 show;
        a = 1; b = 1; #10 show;

        $display("");
        #10 $finish;
    end

    // task = 一段可以重複呼叫的程序（第 4 週會詳細講）
    task show;
        $display("   %b  %b  |   %b     %b     %b     %b",
                 a, b, y_and, y_or, y_not_a, y_xor);
    endtask

endmodule
