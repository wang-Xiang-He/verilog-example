// ============================================================
//  期中考 第 2 題 —— 自動判分測試（不要改這個檔）
// ============================================================
`timescale 1ns / 1ps

module updown_tb;

    localparam W = 4;

    reg clk = 0, rst, load, en, up;
    reg  [W-1:0] din;
    wire [W-1:0] count;
    wire at_max, at_min;

    reg  [W-1:0] model;          // 參考模型
    integer pass = 0, fail = 0, i;

    updown #(.W(W)) uut (
        .clk(clk), .rst(rst), .load(load), .en(en), .up(up),
        .din(din), .count(count), .at_max(at_max), .at_min(at_min)
    );

    always #5 clk = ~clk;

    // 參考模型跟著跑
    always @(posedge clk) begin
        if (rst)       model <= 0;
        else if (load) model <= din;
        else if (en)   model <= up ? model + 1'b1 : model - 1'b1;
    end

    task chk;
        begin
            @(posedge clk); #1;
            if (count === model &&
                at_max === (count == {W{1'b1}}) &&
                at_min === (count == {W{1'b0}})) begin
                pass = pass + 1;
            end else begin
                fail = fail + 1;
                if (fail <= 8)
                    $display("   [X] t=%0t  count=%0d(應該 %0d) at_max=%b(應該 %b) at_min=%b(應該 %b)",
                             $time, count, model,
                             at_max, (count == {W{1'b1}}),
                             at_min, (count == {W{1'b0}}));
            end
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, updown_tb);

        $display("");
        $display("  ========== 期中考 第 2 題：上下數計數器 ==========");
        $display("");

        rst = 1; load = 0; en = 0; up = 1; din = 0;
        @(posedge clk); @(posedge clk); #1 rst = 0;

        $display("   測試 1：往上數 20 拍（會繞回）");
        en = 1; up = 1;
        for (i = 0; i < 20; i = i + 1) chk;

        $display("   測試 2：往下數 20 拍（會繞回）");
        up = 0;
        for (i = 0; i < 20; i = i + 1) chk;

        $display("   測試 3：載入 4'd12 後往上數");
        en = 0; load = 1; din = 4'd12; chk;
        load = 0; en = 1; up = 1;
        for (i = 0; i < 8; i = i + 1) chk;

        $display("   測試 4：en=0 保持不變");
        en = 0;
        for (i = 0; i < 5; i = i + 1) chk;

        $display("   測試 5：優先順序（rst 要蓋過 load）");
        rst = 1; load = 1; din = 4'd7; chk;
        rst = 0; chk;

        $display("   測試 6：亂數操作 200 拍");
        for (i = 0; i < 200; i = i + 1) begin
            rst  = ($random % 20 == 0);
            load = ($random % 7  == 0);
            en   = ($random % 3  != 0);
            up   = $random;
            din  = $random;
            chk;
        end

        $display("");
        $display("  ==================================================");
        $display("     得分：%0d / %0d", pass, pass + fail);
        if (fail == 0) $display("     >>> 全部通過！");
        else           $display("     >>> 有 %0d 個錯", fail);
        $display("  ==================================================");
        $display("");
        $finish;
    end
endmodule
