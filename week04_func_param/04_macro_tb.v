`timescale 1ns / 1ps

`define CHECK(cond, msg) if (!(cond)) begin $display("   [X] %s", msg); errors = errors + 1; end

module macro_demo_tb;
    reg  [7:0] a, b;
    reg  [1:0] state;
    wire [7:0] result;
    wire       is_running;
    integer errors = 0;

    macro_demo uut (.a(a), .b(b), .state(state), .result(result), .is_running(is_running));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, macro_demo_tb);

        $display("");
        $display("   `define DATA_W 8   → 資料寬度 8 位元");
        $display("   `define USE_FAST_ADDER 有定義 → result = a + b");
        $display("");
        $display("    a    b   state | result  is_running");
        $display("   ------------------------------------");

        a = 8'd10; b = 8'd20; state = 2'b00; #10;
        $display("   %3d  %3d    %b   |  %3d       %b   (IDLE)", a, b, state, result, is_running);
        `CHECK(result === 30, "10+20 應該是 30")

        a = 8'd100; b = 8'd50; state = 2'b01; #10;
        $display("   %3d  %3d    %b   |  %3d       %b   (RUN)", a, b, state, result, is_running);
        `CHECK(is_running === 1'b1, "state=RUN 時 is_running 應該是 1")

        a = 8'd7; b = 8'd3; state = 2'b10; #10;
        $display("   %3d  %3d    %b   |  %3d       %b   (DONE)", a, b, state, result, is_running);
        `CHECK(is_running === 1'b0, "state=DONE 時 is_running 應該是 0")

        $display("");
        if (errors == 0) $display("   >>> 全部正確！");
        $display("");
        $display("   ★ 試試看：把 04_macro.v 裡的 `define USE_FAST_ADDER 註解掉");
        $display("     重跑會變成減法 → 10-20 在 8 位元無號數會變成 246");
        $display("     這叫「條件編譯」，同一份原始碼可以編出不同版本");
        $display("");

        #10 $finish;
    end
endmodule
