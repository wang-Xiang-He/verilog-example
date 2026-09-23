// ============================================================
//  第 1 週 範例 2 的測試平台
//  重點：第一次寫「會自己判斷對錯」的測試
// ============================================================
`timescale 1ns / 1ps

module half_adder_tb;

    reg  a, b;
    wire sum, carry;
    integer errors = 0;          // 記錄錯了幾次

    half_adder uut (.a(a), .b(b), .sum(sum), .carry(carry));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, half_adder_tb);

        $display("");
        $display("   a + b  =  carry sum   (十進位)");
        $display("  ---------------------------------");

        a = 0; b = 0; #10 check;
        a = 0; b = 1; #10 check;
        a = 1; b = 0; #10 check;
        a = 1; b = 1; #10 check;

        $display("");
        if (errors == 0)
            $display("  >>> 全部正確！");
        else
            $display("  >>> 有 %0d 個錯誤", errors);
        $display("");

        #10 $finish;
    end

    // 自動比對：{carry,sum} 這兩個位元合起來，應該等於 a+b
    task check;
        begin
            $display("   %b + %b  =    %b    %b     (%0d)",
                     a, b, carry, sum, {carry, sum});
            if ({carry, sum} !== (a + b)) begin
                $display("       ^^^ 錯了！應該是 %0d", a + b);
                errors = errors + 1;
            end
        end
    endtask

endmodule
