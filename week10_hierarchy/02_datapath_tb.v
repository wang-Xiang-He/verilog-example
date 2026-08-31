`timescale 1ns / 1ps

module datapath_tb;
    localparam W = 8;

    reg            clk, rst_n, start;
    reg  [W-1:0]   a, b;
    wire [2*W-1:0] product;
    wire           busy, done;

    integer i, err, cycles;

    datapath_top #(.W(W)) uut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .a(a), .b(b), .product(product), .busy(busy), .done(done)
    );

    always #5 clk = ~clk;

    //  跑一次乘法，回傳花了幾拍
    task run_mult;
        input [W-1:0] x, y;
        begin
            @(negedge clk); a = x; b = y; start = 1;
            @(negedge clk); start = 0;
            cycles = 0;
            while (!done) begin
                @(negedge clk);
                cycles = cycles + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, datapath_tb);
        clk = 0; rst_n = 0; start = 0; a = 0; b = 0; err = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   資料路徑 + 控制器分離：移位相加乘法器");
        $display("  ============================================================");

        // ============================================================
        $display("");
        $display("  ===== 一、一次完整運算的內部過程（13 x 11）=====");
        $display("");
        @(negedge clk); a = 8'd13; b = 8'd11; start = 1;
        @(negedge clk); start = 0;

        $display("   拍 | 狀態 | load shift | mplier   mcand      acc   | busy done");
        $display("   ---+------+------------+---------------------------+----------");
        for (i = 0; i < 11; i = i + 1) begin
            $display("   %2d |  %0d   |   %0d    %0d   | %b %b %5d |  %0d    %0d",
                     i, uut.u_ctrl.state, uut.load, uut.shift_add,
                     uut.u_dp.mplier, uut.u_dp.mcand[7:0], uut.u_dp.acc,
                     busy, done);
            @(negedge clk);
        end
        $display("");
        if (product == 143) $display("   13 x 11 = %0d  （正確答案 143）  ★", product);
        else                $display("   13 x 11 = %0d  （正確答案 143）  [X]", product);
        if (product !== 143) err = err + 1;

        $display("");
        $display("   ★ 看 mplier 那一欄：每拍往右掉一位");
        $display("     它的最低位是 1 的時候，acc 才會加上 mcand");
        $display("     —— 這就是小學的直式乘法，只是換成二進位");

        // ============================================================
        $display("");
        $display("  ===== 二、控制器和資料路徑之間到底傳什麼 =====");
        $display("");
        $display("   控制器 → 資料路徑（控制訊號，共 2 條）：");
        $display("     load       叫你把新的運算元吃進去");
        $display("     shift_add  叫你做一次移位相加");
        $display("");
        $display("   資料路徑 → 控制器（狀態旗標，共 1 條）：");
        $display("     cnt_done   我數完 8 次了");
        $display("");
        $display("   ★ 只有 3 條線。控制器完全不知道 acc 是多少，");
        $display("     資料路徑也完全不知道現在是哪個狀態。");
        $display("     這種「誰都不管誰的細節」就是良好分層的標準。");

        // ============================================================
        $display("");
        $display("  ===== 三、多組驗證（含邊界值）=====");
        $display("");
        $display("      a     b  |  硬體算的  正確答案  拍數");
        $display("   -----------+---------------------------");

        run_mult(8'd13,  8'd11);
        $display("    %3d   %3d |    %5d     %5d    %0d", 13, 11, product, 13*11, cycles);
        if (product !== 13*11) err = err + 1;

        run_mult(8'd255, 8'd255);
        $display("    %3d   %3d |    %5d     %5d    %0d", 255, 255, product, 255*255, cycles);
        if (product !== 255*255) err = err + 1;

        run_mult(8'd0,   8'd99);
        $display("    %3d   %3d |    %5d     %5d    %0d", 0, 99, product, 0, cycles);
        if (product !== 0) err = err + 1;

        run_mult(8'd1,   8'd200);
        $display("    %3d   %3d |    %5d     %5d    %0d", 1, 200, product, 200, cycles);
        if (product !== 200) err = err + 1;

        run_mult(8'd128, 8'd2);
        $display("    %3d   %3d |    %5d     %5d    %0d", 128, 2, product, 256, cycles);
        if (product !== 256) err = err + 1;

        $display("");
        $display("   ===== 隨機 200 組 =====");
        for (i = 0; i < 200; i = i + 1) begin
            a = $random; b = $random;
            run_mult(a, b);
            if (product !== a * b) begin
                err = err + 1;
                if (err <= 3)
                    $display("   [X] %0d x %0d = %0d，應該是 %0d", a, b, product, a*b);
            end
        end

        $display("");
        $display("  ------------------------------------------------------------");
        if (err == 0) $display("   ★ 全部通過，0 個錯");
        else          $display("   [X] 有 %0d 組不符", err);

        $display("");
        $display("   ★★ 為什麼要這樣分？");
        $display("");
        $display("     1. 要改運算方式（例如改成有號數乘法）→ 只動 datapath");
        $display("     2. 要改流程（例如加一個「暫停」狀態）  → 只動 controller");
        $display("     3. 兩個人可以【同時開發】，只要先講好中間那 3 條線");
        $display("     4. 出錯時一眼看得出是「算錯」還是「時序錯」");
        $display("");
        $display("   ★ CPU 就是這個架構放大 100 倍：");
        $display("     控制器 = 指令解碼器，資料路徑 = 暫存器檔 + ALU。");
        $display("     第 16 週的期末專題「簡易 8-bit CPU」就是做這個。");
        $display("");
        $display("   ⚠️ 這顆乘法器要 %0d 拍才算完一次。", cycles);
        $display("      第 12 週會做【單週期】和【三級管線】的乘法器，比較三者差別。");
        $display("");
        #20 $finish;
    end
endmodule
