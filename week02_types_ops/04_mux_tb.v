`timescale 1ns / 1ps

module mux_tb;

    reg  [3:0] d0, d1, d2, d3;
    reg  [1:0] sel;
    wire [3:0] y2, y4;
    integer i, errors = 0;
    reg  [3:0] expect4;

    mux uut (.d0(d0), .d1(d1), .d2(d2), .d3(d3), .sel(sel), .y2(y2), .y4(y4));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, mux_tb);

        // 四路各給一個好認的值
        d0 = 4'hA;  d1 = 4'hB;  d2 = 4'hC;  d3 = 4'hD;

        $display("");
        $display("  d0=A  d1=B  d2=C  d3=D");
        $display("");
        $display("   sel |  y2 (2選1)  y4 (4選1)");
        $display("  -----+----------------------");

        for (i = 0; i < 4; i = i + 1) begin
            sel = i[1:0];
            #20;
            case (sel)
                2'd0: expect4 = d0;
                2'd1: expect4 = d1;
                2'd2: expect4 = d2;
                2'd3: expect4 = d3;
            endcase
            $display("    %b  |     %h          %h", sel, y2, y4);
            if (y4 !== expect4) begin
                $display("        ^^^ 錯了！y4 應該是 %h", expect4);
                errors = errors + 1;
            end
        end

        $display("");
        if (errors == 0) $display("  >>> 全部正確！");
        else             $display("  >>> 有 %0d 個錯誤", errors);
        $display("");
        $display("  ★ 波形上看 y4：sel 一變，y4 立刻跳到對應那一路的值");
        $display("    這就是多工器 —— 一個電子開關");
        $display("");

        #20 $finish;
    end

endmodule
