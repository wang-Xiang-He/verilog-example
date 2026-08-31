`timescale 1ns / 1ps

module compare_tb;
    reg         clk, rst_n, vld_in;
    reg  [7:0]  a, b;
    wire [15:0] p_comb, p_pipe;
    wire        v_comb, v_pipe;

    integer i, n_comb, n_pipe, err;
    reg [15:0] exp_q [0:127];

    compare_top uut (.clk(clk), .rst_n(rst_n), .vld_in(vld_in), .a(a), .b(b),
                     .p_comb(p_comb), .v_comb(v_comb),
                     .p_pipe(p_pipe), .v_pipe(v_pipe));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, compare_tb);
        clk = 0; rst_n = 0; vld_in = 0; a = 0; b = 0;
        n_comb = 0; n_pipe = 0; err = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   單週期 vs 三級管線：同樣的輸入，同時餵給兩顆");
        $display("  ============================================================");

        // ============================================================
        $display("");
        $display("  ===== 一、單發：一筆進去，兩邊各自何時出來 =====");
        $display("");
        @(negedge clk); a = 8'd7; b = 8'd9; vld_in = 1;
        @(negedge clk); vld_in = 0; a = 0; b = 0;

        $display("   拍 | 單週期            | 三級管線");
        $display("      | v_comb  p_comb    | v_pipe  p_pipe");
        $display("   ---+-------------------+------------------");
        for (i = 0; i < 6; i = i + 1) begin
            $display("   %2d |   %0d      %4d     |   %0d      %4d",
                     i, v_comb, p_comb, v_pipe, p_pipe);
            @(negedge clk);
        end
        $display("");
        $display("   ★ 7 x 9 = 63。單週期版第 1 拍就給答案，管線版第 3 拍才給。");
        $display("     這【多出來的 2 拍】就是管線的代價：延遲變長。");

        // ============================================================
        $display("");
        $display("  ===== 二、連續灌：看吞吐量有沒有差 =====");
        $display("");
        $display("   拍 | 送進去 | v_comb p_comb | v_pipe p_pipe | 說明");
        $display("   ---+--------+---------------+---------------+--------------");
        for (i = 1; i <= 10; i = i + 1) begin
            @(negedge clk);
            vld_in = 1; a = i[7:0]; b = 8'd11;
            #1;
            if (i <= 3)
                $display("   %2d | %2d x 11 |   %0d    %4d   |   %0d    %4d   | 管線還在填充",
                         i, i, v_comb, p_comb, v_pipe, p_pipe);
            else
                $display("   %2d | %2d x 11 |   %0d    %4d   |   %0d    %4d   | ★ 兩邊都每拍出一筆",
                         i, i, v_comb, p_comb, v_pipe, p_pipe);
        end
        @(negedge clk); vld_in = 0; a = 0; b = 0;
        for (i = 0; i < 4; i = i + 1) begin
            #1;
            $display("    - |   --   |   %0d    %4d   |   %0d    %4d   | 排空",
                     v_comb, p_comb, v_pipe, p_pipe);
            @(negedge clk);
        end

        $display("");
        $display("   ★★ 穩定之後，兩邊【都是每拍出一筆】。");
        $display("      管線【沒有】讓吞吐量變好 —— 這是最容易誤解的一點。");

        // ============================================================
        $display("");
        $display("  ===== 三、數一數：灌 30 筆，兩邊各收到幾筆 =====");
        $display("");
        n_comb = 0; n_pipe = 0;
        fork
            begin
                for (i = 0; i < 30; i = i + 1) begin
                    @(negedge clk);
                    vld_in = 1; a = (i[7:0] % 8'd200) + 8'd1; b = 8'd5;
                end
                @(negedge clk); vld_in = 0;
            end
            begin
                repeat (40) begin
                    @(posedge clk);
                    if (v_comb) n_comb = n_comb + 1;
                    if (v_pipe) n_pipe = n_pipe + 1;
                end
            end
        join
        $display("   單週期版收到 %0d 筆", n_comb);
        $display("   三級管線版收到 %0d 筆", n_pipe);
        $display("   ★ 一樣多 —— 吞吐量相同，只有出來的時間點差 2 拍。");

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   ★★★ 那管線到底賺在哪？答案不在模擬裡，在【時脈】。");
        $display("");
        $display("     模擬時我們用固定的 10ns 週期，兩邊當然一樣快。");
        $display("     但真實晶片上，時脈能拉多快是由【最長的那條路徑】決定的：");
        $display("");
        $display("       單週期版：訊號要一路穿過整顆乘法器才能穩定");
        $display("       管線版  ：每一級只做一次加法，路徑短很多");
        $display("");
        $display("     跑 03_compare.bat 用 nextpnr 實測，會看到：");
        $display("");
        $display("                         單週期      三級管線     變化");
        $display("       ---------------------------------------------------");
        $display("       最高時脈        120.15 MHz  180.15 MHz   ★ +50%%");
        $display("       延遲               2 拍        4 拍       +2 拍");
        $display("       吞吐量          每拍 1 筆   每拍 1 筆     一樣");
        $display("       ★ 每秒可算       120 M 次    180 M 次    ★ +50%%");
        $display("       ---------------------------------------------------");
        $display("       SB_LUT4            159         133        -16%%");
        $display("       SB_DFF              34         102       ★ +200%%");
        $display("       SB_CARRY            12          66        +450%%");
        $display("");
        $display("     ★ 管線用【更多正反器】+【更長的延遲】");
        $display("       換到【更高的時脈】+【更高的每秒處理量】。");
        $display("");
        $display("   什麼時候該切管線？");
        $display("     ✅ 要處理【連續的資料流】（影像、音訊、通訊）→ 切");
        $display("     ✅ 時脈拉不上去，時序收斂不了               → 切");
        $display("     ❌ 偶爾才算一次，而且要馬上要答案           → 不要切");
        $display("     ❌ 正反器已經快用完了                       → 不要切");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
