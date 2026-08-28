`timescale 1ns / 1ps

module case_mux_tb;
    reg  [3:0] d0, d1, d2, d3;
    reg  [1:0] sel;
    wire [3:0] y;
    wire [7:0] decoded;
    integer i;

    case_mux uut (.d0(d0), .d1(d1), .d2(d2), .d3(d3), .sel(sel), .y(y), .decoded(decoded));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, case_mux_tb);

        d0 = 4'hA; d1 = 4'hB; d2 = 4'hC; d3 = 4'hD;

        $display("");
        $display("   sel |  y   decoded");
        $display("  -----+---------------");
        for (i = 0; i < 4; i = i + 1) begin
            sel = i[1:0]; #20;
            $display("    %b  |  %h   %b", sel, y, decoded);
        end
        $display("");
        $display("  ★ decoded 永遠只有一個位元是 1 —— 這叫 one-hot 編碼");
        $display("    第 6 週的狀態機會用到");
        $display("");
        #20 $finish;
    end
endmodule
