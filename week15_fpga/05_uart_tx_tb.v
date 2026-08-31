`timescale 1ns / 1ps

module uart_tx_tb;
    localparam CLK_HZ = 10_000;
    localparam BAUD   = 1_000;             // 每位 10 拍，模擬跑得快
    localparam TICKS  = CLK_HZ / BAUD;

    reg        clk, rst_n, send;
    reg  [7:0] data;
    wire       tx, busy;

    integer i, err;
    reg [7:0] rx_byte;

    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) uut (
        .clk(clk), .rst_n(rst_n), .send(send), .data(data),
        .tx(tx), .busy(busy));

    always #5 clk = ~clk;

    // ============================================================
    //  ★ 寫一個簡單的接收器來驗證發送器
    //    這是驗證通訊電路的標準作法：自己做一個對面的角色
    // ============================================================
    task receive_byte;
        output [7:0] b;
        integer k;
        begin
            //  等起始位元（tx 從 1 掉到 0）
            @(negedge tx);
            //  ★ 對齊到位元中央再取樣 —— 這是 UART 接收的關鍵技巧
            //    在邊緣附近取樣很容易取到錯的值
            repeat (TICKS + TICKS/2) @(posedge clk);
            for (k = 0; k < 8; k = k + 1) begin
                b[k] = tx;                       // LSB first
                repeat (TICKS) @(posedge clk);
            end
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, uart_tx_tb);
        clk = 0; rst_n = 0; send = 0; data = 0; err = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   UART 發送器：第一個和外界通訊的電路");
        $display("  ============================================================");
        $display("");
        $display("   模擬參數：CLK_HZ=%0d, BAUD=%0d → 每位 %0d 拍",
                 CLK_HZ, BAUD, TICKS);
        $display("   （上板時是 12MHz / 115200 = 104 拍）");

        // ============================================================
        $display("");
        $display("  ===== 一、送一個字元 'A' (0x41)，看線上的波形 =====");
        $display("");
        fork
            begin
                @(negedge clk); data = 8'h41; send = 1;
                @(negedge clk); send = 0;
            end
            begin
                receive_byte(rx_byte);
            end
        join

        $display("   送出去的：0x%h ('%c')", 8'h41, 8'h41);
        $display("   收到的  ：0x%h ('%c')", rx_byte, rx_byte);
        if (rx_byte === 8'h41) $display("   ★ 一致");
        else begin $display("   [X] 不符"); err = err + 1; end

        $display("");
        $display("   0x41 的二進位是 %b", 8'h41);
        $display("   線上的順序（LSB first）：起始 0 → 1 0 0 0 0 0 1 0 → 停止 1");
        $display("                                    ^^^^^^^^^^^^^^^");
        $display("                                    ★ 是【反過來】的");

        // ============================================================
        $display("");
        $display("  ===== 二、連續送 'H' 'e' 'l' 'l' 'o' =====");
        $display("");
        $display("   送出 | 收到 | 字元");
        $display("   -----+------+------");
        for (i = 0; i < 5; i = i + 1) begin
            case (i)
                0: data = 8'h48;
                1: data = 8'h65;
                2: data = 8'h6C;
                3: data = 8'h6C;
                4: data = 8'h6F;
            endcase
            fork
                begin
                    @(negedge clk); send = 1;
                    @(negedge clk); send = 0;
                    @(negedge busy);
                end
                receive_byte(rx_byte);
            join
            $display("   0x%h | 0x%h |  %c", data, rx_byte, rx_byte);
            if (rx_byte !== data) err = err + 1;
            repeat (TICKS * 2) @(negedge clk);
        end

        $display("");
        if (err == 0) $display("   ★ 全部正確");
        else          $display("   [X] 有 %0d 個錯", err);

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   ★★ 三個實戰重點");
        $display("");
        $display("   1. 鮑率誤差【一定要算】");
        $display("      12MHz / 115200 = 104.17 → 只能取 104");
        $display("      實際每位 8.667us，理想 8.681us，誤差 0.16%%");
        $display("      UART 容許約 ±2%%（10 位元累積不能超過半位元）");
        $display("      → 0.16%% 沒問題");
        $display("      ⚠️ 但如果誤差 3%%，前面幾位還對，後面就整個歪掉，");
        $display("         症狀是「偶爾收到亂碼」，非常難查。");
        $display("");
        $display("   2. tx 這條線【一定要上正反器】");
        $display("      用組合邏輯的話會有毛刺（第 7 週 02_glitch），");
        $display("      一個毛刺就會被對方當成起始位元，整包資料錯掉。");
        $display("");
        $display("   3. 接收時要【對齊到位元中央】取樣");
        $display("      本測試平台的 receive_byte 就是這樣做的：");
        $display("      收到起始邊緣後先等 1.5 個位元時間，才開始每隔");
        $display("      1 個位元時間取一次。在邊緣附近取樣很容易取錯。");
        $display("");
        $display("   ★ 上板子之後：");
        $display("     build.bat 05_uart_tx uart_tx_top");
        $display("     燒進去，接 USB 轉序列埠，PuTTY 開 115200 8N1，");
        $display("     就會看到 A B C ... Z 一秒一個跳出來。");
        $display("");
        $display("   ★ 這顆發送器 = 第 3 週 14_shift_4types 的 PISO");
        $display("                 + 第 6 週的三段式狀態機");
        $display("                 + 第 3 週 15_freq_div 的 tick 產生器");
        $display("     全部都是前面學過的東西組起來的。");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
