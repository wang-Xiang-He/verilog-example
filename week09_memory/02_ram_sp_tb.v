`timescale 1ns / 1ps

module ram_sp_tb;
    localparam AW = 4, DW = 8;

    reg clk = 0, we;
    reg  [AW-1:0] addr;
    reg  [DW-1:0] din;
    wire [DW-1:0] dout;
    integer i, errors = 0;
    reg  [DW-1:0] model [0:15];

    ram_sp #(.AW(AW), .DW(DW)) uut (.clk(clk), .we(we), .addr(addr), .din(din), .dout(dout));
    always #5 clk = ~clk;

    task wr(input [AW-1:0] a, input [DW-1:0] d);
        begin
            addr = a; din = d; we = 1;
            @(posedge clk); #1;
            model[a] = d;
            we = 0;
        end
    endtask

    task rd(input [AW-1:0] a);
        begin
            addr = a; we = 0;
            @(posedge clk); #1;
            if (dout !== model[a]) begin
                $display("   [X] 位址 %0d 讀到 %h，應該是 %h", a, dout, model[a]);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, ram_sp_tb);

        for (i = 0; i < 16; i = i + 1) model[i] = 0;
        we = 0; addr = 0; din = 0;
        @(posedge clk); #1;

        $display("");
        $display("   ===== 寫入 16 格 =====");
        for (i = 0; i < 16; i = i + 1) begin
            wr(i[AW-1:0], 8'hA0 + i[7:0]);
            $display("    寫 mem[%2d] = %h", i, 8'hA0 + i[7:0]);
        end

        $display("");
        $display("   ===== 讀回來比對 =====");
        for (i = 0; i < 16; i = i + 1) begin
            rd(i[AW-1:0]);
            $display("    讀 mem[%2d] = %h", i, dout);
        end

        $display("");
        $display("   ===== 亂數讀寫 300 次 =====");
        for (i = 0; i < 300; i = i + 1) begin
            if ($random % 2) wr($random, $random);
            else             rd($random);
        end

        $display("");
        if (errors == 0) $display("   >>> 全部正確！");
        else             $display("   >>> 有 %0d 個錯", errors);
        $display("");
        $display("  ★ 波形上看：we 拉高的那一拍資料寫進去，");
        $display("    dout 永遠比 addr 晚一拍（同步讀取）");
        $display("");
        $display("  ★ 單埠 = 只有一組 addr。想同時讀 A 又寫 B 做不到，");
        $display("    要用雙埠 RAM（下一個範例）");
        $display("");
        $finish;
    end
endmodule
