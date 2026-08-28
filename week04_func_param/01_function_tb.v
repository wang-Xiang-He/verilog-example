`timescale 1ns / 1ps

module func_demo_tb;
    reg  [7:0] a, b;
    wire       parity_a;
    wire [7:0] max_val;
    wire [3:0] ones_count;
    integer errors = 0;

    func_demo uut (.a(a), .b(b), .parity_a(parity_a),
                   .max_val(max_val), .ones_count(ones_count));

    task chk;
        begin
            #10;
            $display("   a=%b(%3d) b=%b(%3d) | 奇同位=%b  較大者=%3d  a裡有%0d個1",
                     a, a, b, b, parity_a, max_val, ones_count);
            if (max_val !== ((a > b) ? a : b)) begin
                $display("       ^^^ maximum 錯了"); errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, func_demo_tb);
        $display("");
        a = 8'b0000_0001; b = 8'd100; chk;
        a = 8'b0000_0011; b = 8'd2;   chk;
        a = 8'b1111_1111; b = 8'd200; chk;
        a = 8'b1010_1010; b = 8'd170; chk;
        a = 8'b0000_0000; b = 8'd0;   chk;
        $display("");
        if (errors == 0) $display("  >>> 全部正確！");
        $display("");
        $display("  ★ function 會被完全展開成組合邏輯，不佔時脈");
        $display("    count_ones 裡的 for 迴圈也是 —— 綜合時會展開成 8 個加法器");
        $display("");
        #10 $finish;
    end
endmodule
