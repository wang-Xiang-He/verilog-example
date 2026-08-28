`timescale 1ns / 1ps

module vending_tb;
    reg clk = 0, rst, coin5, coin10;
    wire dispense;
    wire [1:0] change;
    wire [2:0] total_out;
    integer drinks = 0;

    vending uut (.clk(clk), .rst(rst), .coin5(coin5), .coin10(coin10),
                 .dispense(dispense), .change(change), .total_out(total_out));
    always #5 clk = ~clk;

    // 出貨時記帳
    always @(posedge clk) begin
        if (dispense) drinks = drinks + 1;
    end

    task put5;
        begin
            coin5 = 1;
            @(posedge clk); #1;
            coin5 = 0;
            if (dispense)
                $display("      投 5 元  -> 出貨！找零 %0d 元", change * 5);
            else
                $display("      投 5 元  -> 累積 %0d 元", total_out * 5);
            @(posedge clk); #1;
        end
    endtask

    task put10;
        begin
            coin10 = 1;
            @(posedge clk); #1;
            coin10 = 0;
            if (dispense)
                $display("      投 10 元 -> 出貨！找零 %0d 元", change * 5);
            else
                $display("      投 10 元 -> 累積 %0d 元", total_out * 5);
            @(posedge clk); #1;
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, vending_tb);

        $display("");
        $display("   飲料 25 元，可投 5 元 / 10 元");
        $display("");

        rst = 1; coin5 = 0; coin10 = 0;
        @(posedge clk); @(posedge clk); #1 rst = 0;

        $display("   情境 1：投 5 個 5 元（剛好 25，不用找零）");
        put5; put5; put5; put5; put5;

        $display("");
        $display("   情境 2：投 3 個 10 元（30 元，要找 5 元）");
        put10; put10; put10;

        $display("");
        $display("   情境 3：混合 10+10+5（剛好 25）");
        put10; put10; put5;

        $display("");
        $display("   情境 4：再來一次 10+10+10");
        put10; put10; put10;

        #50;
        $display("");
        if (drinks == 4)
            $display("  >>> 正確！總共買了 4 瓶");
        else
            $display("  >>> 錯誤！應該是 4 瓶，實際 %0d 瓶", drinks);
        $display("");
        $display("  ★ 看波形：total_out 是累積金額/5，一路往上加，");
        $display("    湊到 25 元時 dispense 拉高一拍，然後歸零");
        $display("    change 只有在需要找零時才不是 0");
        $display("");
        $finish;
    end
endmodule
