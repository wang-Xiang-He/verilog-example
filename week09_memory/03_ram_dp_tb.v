`timescale 1ns / 1ps

module ram_dp_tb;
    localparam AW = 4, DW = 8;

    reg clk = 0, a_we;
    reg  [AW-1:0] a_addr, b_addr;
    reg  [DW-1:0] a_din;
    wire [DW-1:0] b_dout;
    integer i, errors = 0;
    reg  [DW-1:0] model [0:15];

    ram_dp #(.AW(AW), .DW(DW)) uut (
        .clk(clk), .a_we(a_we), .a_addr(a_addr), .a_din(a_din),
        .b_addr(b_addr), .b_dout(b_dout)
    );
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, ram_dp_tb);

        for (i = 0; i < 16; i = i + 1) model[i] = 0;
        a_we = 0; a_addr = 0; a_din = 0; b_addr = 0;
        @(posedge clk); #1;

        $display("");
        $display("   雙埠 RAM：A 埠寫入的同時，B 埠可以讀別的位址");
        $display("");

        // 先塞初始資料
        for (i = 0; i < 16; i = i + 1) begin
            a_we = 1; a_addr = i[AW-1:0]; a_din = 8'h10 + i[7:0];
            @(posedge clk); #1;
            model[i] = 8'h10 + i[7:0];
        end
        a_we = 0;
        @(posedge clk); #1;

        $display("    拍 | A埠寫          | B埠讀");
        $display("   ----+----------------+------------------");

        // 關鍵示範：同一拍，A 寫位址 i，B 讀位址 15-i
        for (i = 0; i < 8; i = i + 1) begin
            a_we   = 1;
            a_addr = i[AW-1:0];
            a_din  = 8'hF0 + i[7:0];
            b_addr = (15 - i);
            @(posedge clk); #1;
            model[i] = 8'hF0 + i[7:0];

            $display("    %2d | mem[%2d] <= %h  | mem[%2d] => %h",
                     i, a_addr, a_din, b_addr, b_dout);
            if (b_dout !== model[15-i]) begin
                $display("        [X] B 埠應該讀到 %h", model[15-i]);
                errors = errors + 1;
            end
        end

        a_we = 0;
        @(posedge clk); #1;

        $display("");
        if (errors == 0) $display("   >>> 全部正確！A 寫 B 讀同時進行，沒有衝突");
        else             $display("   >>> 有 %0d 個錯", errors);
        $display("");
        $display("  ★ 雙埠 RAM 的典型用途：");
        $display("     - FIFO（一邊寫入、一邊讀出）");
        $display("     - 影像緩衝（一邊接收畫面、一邊送去顯示）");
        $display("     - 跨時脈域傳資料（兩個埠各接一個時脈）");
        $display("");
        $display("  ★ 注意衝突：同一拍如果 a_addr == b_addr 而且 a_we=1，");
        $display("    B 讀到新值還是舊值取決於硬體，不要依賴它。");
        $display("");
        $finish;
    end
endmodule
