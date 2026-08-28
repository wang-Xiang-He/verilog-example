`timescale 1ns / 1ps

module shift_reg_tb;
    reg clk = 0, rst, sin;
    reg  [1:0] mode;
    reg  [7:0] load_data;
    wire [7:0] q;

    localparam HOLD = 2'b00, LEFT = 2'b01, RIGHT = 2'b10, LOAD = 2'b11;

    shift_reg uut (.clk(clk), .rst(rst), .mode(mode), .sin(sin),
                   .load_data(load_data), .q(q));

    always #5 clk = ~clk;

    // 設定 mode/sin，走一拍，等更新完成
    task step(input [1:0] m, input s);
        begin
            mode = m; sin = s;
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, shift_reg_tb);

        rst = 1; mode = HOLD; sin = 0; load_data = 8'b1100_0011;
        @(posedge clk); @(posedge clk); #1 rst = 0;

        $display("");
        $display("   動作            q");
        $display("  ------------------------------");
        step(LOAD,  0);  $display("   載入 8'hC3      %b", q);
        step(LEFT,  1);  $display("   左移 sin=1      %b", q);
        step(LEFT,  0);  $display("   左移 sin=0      %b", q);
        step(LEFT,  1);  $display("   左移 sin=1      %b", q);
        step(HOLD,  0);  $display("   保持            %b", q);
        step(HOLD,  0);  $display("   保持            %b", q);
        step(RIGHT, 1);  $display("   右移 sin=1      %b", q);
        step(RIGHT, 0);  $display("   右移 sin=0      %b", q);
        step(LOAD,  0);  $display("   重新載入        %b", q);

        $display("");
        $display("  ★ 看波形：q 這條 8 位元的線，每個時脈整體往左或往右滑一格");
        $display("    左移 {q[6:0], sin} —— 丟掉最高位，最低位補 sin");
        $display("    右移 {sin, q[7:1]} —— 丟掉最低位，最高位補 sin");
        $display("    保持那兩拍 q 完全不動 —— 這就是「有記憶」");
        $display("");

        #20 $finish;
    end
endmodule
