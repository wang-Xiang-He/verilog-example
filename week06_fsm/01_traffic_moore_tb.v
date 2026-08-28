`timescale 1ns / 1ps

module traffic_tb;
    reg clk = 0, rst;
    wire [2:0] light;
    wire [1:0] state_out;
    integer i;

    traffic uut (.clk(clk), .rst(rst), .light(light), .state_out(state_out));
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, traffic_tb);

        $display("");
        $display("   拍  狀態      燈號(紅黃綠)");
        $display("  --------------------------------");

        rst = 1;
        @(posedge clk); @(posedge clk); #1 rst = 0;

        for (i = 0; i < 24; i = i + 1) begin
            @(posedge clk); #1;
            case (state_out)
                2'd0: $display("   %2d  RED       %b", i, light);
                2'd1: $display("   %2d  GREEN     %b", i, light);
                2'd2: $display("   %2d  YELLOW    %b", i, light);
                default: $display("   %2d  ???       %b", i, light);
            endcase
        end

        $display("");
        $display("  ★ 循環：RED(5拍) → GREEN(4拍) → YELLOW(2拍) → RED …");
        $display("");
        $display("  ★ 在 GTKWave 看 state 這條線：");
        $display("    在 state 名字上按右鍵 → Data Format → ASCII");
        $display("    （或用 Decimal 看 0/1/2）");
        $display("");
        $display("  ★★ 三段式寫法（背起來）：");
        $display("     第1段 always @(posedge clk)  狀態暫存器   用 <=");
        $display("     第2段 always @(*)            下一狀態邏輯 用 =");
        $display("     第3段 always @(*)            輸出邏輯     用 =");
        $display("");
        $finish;
    end
endmodule
