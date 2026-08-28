// ============================================================
//  第 1 週 範例 3 的測試平台
//  重點：用 for 迴圈窮舉 8 種輸入，自動比對
// ============================================================
`timescale 1ns / 1ps

module full_adder_tb;

    reg  a, b, cin;
    wire sum, cout;
    integer i;
    integer errors = 0;

    full_adder uut (
        .a(a), .b(b), .cin(cin),
        .sum(sum), .cout(cout)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, full_adder_tb);

        $display("");
        $display("   a  b  cin  |  cout  sum   =  十進位");
        $display("  ------------+----------------------");

        // 3 個輸入 → 2^3 = 8 種組合，用迴圈跑完
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i[2:0];      // 把 i 的 3 個位元拆給 a,b,cin
            #10;
            $display("   %b  %b   %b   |   %b     %b    =    %0d",
                     a, b, cin, cout, sum, {cout, sum});
            if ({cout, sum} !== (a + b + cin)) begin
                $display("        ^^^ 錯了！應該是 %0d", a + b + cin);
                errors = errors + 1;
            end
        end

        $display("");
        if (errors == 0)
            $display("  >>> 8 種組合全部正確！");
        else
            $display("  >>> 有 %0d 個錯誤", errors);
        $display("");

        #10 $finish;
    end

endmodule
