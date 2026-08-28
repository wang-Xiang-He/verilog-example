`timescale 1ns / 1ps

module param_counter_tb;
    reg clk = 0, rst, en;

    // ★ 同一個模組，用不同參數實例化三次 → 三個不同大小的電路
    wire [3:0] c_bcd;    wire t_bcd;
    wire [3:0] c_hex;    wire t_hex;
    wire [7:0] c_wide;   wire t_wide;

    param_counter #(.WIDTH(4), .MAX(9))   u_bcd  (.clk(clk), .rst(rst), .en(en), .count(c_bcd),  .tick(t_bcd));
    param_counter #(.WIDTH(4), .MAX(15))  u_hex  (.clk(clk), .rst(rst), .en(en), .count(c_hex),  .tick(t_hex));
    param_counter #(.WIDTH(8), .MAX(20))  u_wide (.clk(clk), .rst(rst), .en(en), .count(c_wide), .tick(t_wide));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, param_counter_tb);

        $display("");
        $display("   同一份程式碼，三種參數：");
        $display("     u_bcd : WIDTH=4 MAX=9    十進位計數器");
        $display("     u_hex : WIDTH=4 MAX=15   十六進位計數器");
        $display("     u_wide: WIDTH=8 MAX=20   0~20 計數器");
        $display("");
        $display("    拍  |  bcd(0-9)  hex(0-F)  wide(0-20)");
        $display("   -----+-------------------------------");

        rst = 1; en = 0;
        @(posedge clk); @(posedge clk); #1 rst = 0; en = 1;

        repeat (24) begin
            @(posedge clk); #1;
            $display("        |    %2d %s      %2d %s      %2d %s",
                     c_bcd,  t_bcd  ? "*" : " ",
                     c_hex,  t_hex  ? "*" : " ",
                     c_wide, t_wide ? "*" : " ");
        end

        $display("");
        $display("  ★ 星號 * 是 tick（數到頂）。三個計數器歸零的時機都不一樣");
        $display("    bcd 在 9 歸零、hex 在 15 歸零、wide 在 20 歸零");
        $display("    程式碼只有一份！");
        $display("");
        $finish;
    end
endmodule
