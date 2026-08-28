`timescale 1ns / 1ps

module ripple_adder_tb;
    localparam N = 8;

    reg  [N-1:0] a, b;
    reg          cin;
    wire [N-1:0] sum;
    wire         cout;
    wire [N:0]   expected;
    integer i, errors = 0;

    ripple_adder #(.N(N)) uut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    assign expected = a + b + cin;

    task chk;
        begin
            #10;
            if ({cout, sum} !== expected) begin
                $display("   [X] %0d + %0d + %0d = %0d，應該是 %0d",
                         a, b, cin, {cout, sum}, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, ripple_adder_tb);

        $display("");
        $display("   用 generate 產生的 %0d 位元加法器", N);
        $display("");
        $display("      a  +   b  + cin =  cout sum   (十進位)");
        $display("   ------------------------------------------");

        a=8'd0;   b=8'd0;   cin=0; chk; $display("    %4d + %4d +  %0d  =   %b  %3d", a,b,cin,cout,sum);
        a=8'd1;   b=8'd1;   cin=0; chk; $display("    %4d + %4d +  %0d  =   %b  %3d", a,b,cin,cout,sum);
        a=8'd100; b=8'd55;  cin=0; chk; $display("    %4d + %4d +  %0d  =   %b  %3d", a,b,cin,cout,sum);
        a=8'd200; b=8'd100; cin=0; chk; $display("    %4d + %4d +  %0d  =   %b  %3d  ← 超過 255 了，cout=1", a,b,cin,cout,sum);
        a=8'd255; b=8'd0;   cin=1; chk; $display("    %4d + %4d +  %0d  =   %b  %3d", a,b,cin,cout,sum);
        a=8'd255; b=8'd255; cin=1; chk; $display("    %4d + %4d +  %0d  =   %b  %3d", a,b,cin,cout,sum);

        // 亂數壓測
        for (i = 0; i < 200; i = i + 1) begin
            a = $random; b = $random; cin = $random;
            chk;
        end

        $display("");
        if (errors == 0) $display("   >>> 含 200 組亂數測試，全部正確！");
        else             $display("   >>> 有 %0d 個錯誤", errors);
        $display("");
        $display("   ★ generate 的 for 不是「跑迴圈」，是「複製 8 顆全加器」");
        $display("     在 GTKWave 左邊的樹會看到 adder_stage[0] ~ adder_stage[7]");
        $display("");
        #10 $finish;
    end
endmodule
