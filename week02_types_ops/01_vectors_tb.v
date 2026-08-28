`timescale 1ns / 1ps

module vectors_tb;

    reg  [7:0] data;
    wire [3:0] high, low;
    wire       msb, lsb;
    wire [2:0] middle;
    integer i;

    vectors uut (
        .data(data), .high(high), .low(low),
        .msb(msb), .lsb(lsb), .middle(middle)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, vectors_tb);

        $display("");
        $display("  ===== 數字的四種寫法（都是同一個值 165）=====");
        $display("   二進位 8'b1010_0101 = %0d", 8'b1010_0101);
        $display("   十六進位 8'hA5      = %0d", 8'hA5);
        $display("   十進位 8'd165       = %0d", 8'd165);
        $display("   八進位 8'o245       = %0d", 8'o245);
        $display("   （底線 _ 只是給人看的，電腦會忽略）");
        $display("");
        $display("  ===== 切片 =====");
        $display("   data      high  low   msb lsb  middle");
        $display("  ---------------------------------------");

        for (i = 0; i < 256; i = i + 43) begin
            data = i[7:0];
            #10;
            $display("   %b  %b  %b   %b   %b   %b",
                     data, high, low, msb, lsb, middle);
        end

        data = 8'hA5; #10;
        $display("");
        $display("   data = 8'hA5 = %b", data);
        $display("     data[7:4] = %b  (高 4 位)", high);
        $display("     data[3:0] = %b  (低 4 位)", low);
        $display("     data[7]   = %b  (最高位 MSB)", msb);
        $display("     data[0]   = %b  (最低位 LSB)", lsb);
        $display("");

        #10 $finish;
    end

endmodule
