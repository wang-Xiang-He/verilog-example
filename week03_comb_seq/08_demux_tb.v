`timescale 1ns / 1ps

module demux_tb;
    reg        din, en;
    reg  [2:0] sel;
    wire [7:0] dout, dout_bus;
    integer i;

    demux uut (.din(din), .sel(sel), .en(en), .dout(dout), .dout_bus(dout_bus));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, demux_tb);

        $display("");
        $display("  ===== 解多工器：一條進、八條出 =====");
        $display("");
        $display("   en  din  sel |   dout     |  dout_bus");
        $display("   -------------+------------+------------");
        en = 1; din = 1;
        for (i = 0; i < 8; i = i + 1) begin
            sel = i[2:0]; #10;
            $display("    %0d   %0d    %0d  |  %b  |  %b", en, din, sel, dout, dout_bus);
        end

        $display("");
        $display("   ---- din 改成 0 ----");
        din = 0;
        for (i = 0; i < 3; i = i + 1) begin
            sel = i[2:0]; #10;
            $display("    %0d   %0d    %0d  |  %b  |  %b", en, din, sel, dout, dout_bus);
        end

        $display("");
        $display("   ---- en 關掉 ----");
        en = 0; din = 1; sel = 3'd5; #10;
        $display("    %0d   %0d    %0d  |  %b  |  %b", en, din, sel, dout, dout_bus);

        $display("");
        $display("   ★ 兩個版本的差別：");
        $display("     dout     沒選到的送 0  → 適合單獨拉線給下一級");
        $display("     dout_bus 沒選到的送 z  → 適合多個裝置共用一條匯流排");
        $display("");
        $display("   ★ 對照第 2 週的 04_mux：");
        $display("     多工器   八選一 → 一條出  （收斂）");
        $display("     解多工器 一條進 → 八選一送（發散）");
        $display("");
        #20 $finish;
    end
endmodule
