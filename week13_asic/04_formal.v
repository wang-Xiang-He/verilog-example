// ============================================================
//  W13-4：形式驗證 —— 用【數學證明】你的設計永遠不會錯
//  重點：★★ 模擬只能證明「你想到的那些情況是對的」，
//            形式驗證能證明「【所有】情況都是對的」。
//
//  為什麼 ASIC 特別需要這個？
//    FPGA 錯了 → 重燒，5 秒
//    ASIC 錯了 → 重跑光罩，幾千萬台幣 + 3~6 個月
//  所以關鍵性質不能只靠「測了很多組都對」，要靠證明。
//
//  工具：SymbiYosys (sby) + z3 定理證明器（OSS CAD Suite 內建）
// ============================================================
`timescale 1ns / 1ps

// ============================================================
//  ★ 有 bug 的 FIFO
//
//  bug 在哪：full 旗標【晚一拍】才出來（不小心把它上了正反器）。
//
//  這是真實世界很常見的一種 bug，而且【非常難用模擬抓到】：
//    - 平常讀寫交錯的時候完全正常
//    - 只有在「連續寫到剛好滿的那一拍又再寫一次」才會出事
//    - 那一拍 full 還是舊的 0，所以多寫進去一筆 → 資料被蓋掉
//
//  隨機測試要剛好連續灌滿 8 筆中間一次都不讀，機率不高；
//  就算灌到了，錯的是「某一筆資料不見」，很容易被當成別的問題。
//
//  ★ 但形式驗證會在幾秒內把觸發它的完整輸入序列算給你看。
// ============================================================
module fifo_buggy #(
    parameter DW = 8,
    parameter AW = 3                       // 深度 8
) (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          wr,
    input  wire          rd,
    input  wire [DW-1:0] din,
    output wire [DW-1:0] dout,
    output wire          empty,
    output wire          full,
    output wire [AW:0]   count
);
    reg [DW-1:0] mem [0:(1<<AW)-1];
    reg [AW:0]   wp, rp;

    assign empty = (wp == rp);
    assign count = wp - rp;
    assign dout  = mem[rp[AW-1:0]];

    //  判斷式本身是【對的】
    wire full_comb = (wp[AW] != rp[AW]) && (wp[AW-1:0] == rp[AW-1:0]);

    //  ❌ BUG：把 full 上了一級正反器，於是它【晚一拍】才反應。
    //     FIFO 在第 N 拍就滿了，但 full 要到第 N+1 拍才變 1，
    //     中間那一拍的寫入會擋不住 → 溢位、舊資料被蓋掉。
    reg full_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) full_r <= 1'b0;
        else        full_r <= full_comb;
    end
    assign full = full_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wp <= 0; rp <= 0;
        end else begin
            if (wr && !full)  begin mem[wp[AW-1:0]] <= din; wp <= wp + 1; end
            if (rd && !empty) rp <= rp + 1;
        end
    end

`ifdef FORMAL
    // --------------------------------------------------------
    //  ★ 性質（property）：我們要證明的東西
    //
    //  assert = 「這件事永遠成立」，證明器要嘛證明它、
    //           要嘛找出一組讓它不成立的輸入（反例 counterexample）
    // --------------------------------------------------------

    //  ★★ 這一行非常重要，少了它整個驗證都是假的：
    //
    //  形式驗證的【初始狀態是任意的】—— 證明器會假設 wp/rp
    //  一開始就可以是任何值（例如 wp=0, rp=1，那 count 就變成 15）。
    //  那樣抓到的「錯誤」不是你的 bug，是「沒有先 reset」。
    //
    //  assume = 「我保證這個條件成立，你不用去試不成立的情況」。
    //  這裡保證電路一開始是在 reset 狀態，和真實使用方式一致。
    initial assume (!rst_n);

    reg past_valid = 0;
    always @(posedge clk) past_valid <= 1;

    always @(posedge clk) begin
        if (past_valid && rst_n) begin
            //  性質 1：資料筆數不可以超過容量
            assert (count <= (1 << AW));

            //  性質 2：空和滿不可以同時成立
            assert (!(empty && full));
        end
    end
`endif
endmodule


// ============================================================
//  ✅ 修好的版本
//  full 改成【純組合邏輯】，同一拍就反應，寫入才擋得住。
//  （這就是第 9 週 04_fifo 和 06_stack_queue 用的正確寫法）
// ============================================================
module fifo_fixed #(
    parameter DW = 8,
    parameter AW = 3
) (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          wr,
    input  wire          rd,
    input  wire [DW-1:0] din,
    output wire [DW-1:0] dout,
    output wire          empty,
    output wire          full,
    output wire [AW:0]   count
);
    reg [DW-1:0] mem [0:(1<<AW)-1];
    reg [AW:0]   wp, rp;

    assign empty = (wp == rp);

    //  ✅ 正確：低位元相同【而且】最高位不同 → 滿
    //     低位元相同【而且】最高位也相同 → 空
    assign full  = (wp[AW] != rp[AW]) && (wp[AW-1:0] == rp[AW-1:0]);

    assign count = wp - rp;
    assign dout  = mem[rp[AW-1:0]];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wp <= 0; rp <= 0;
        end else begin
            if (wr && !full)  begin mem[wp[AW-1:0]] <= din; wp <= wp + 1; end
            if (rd && !empty) rp <= rp + 1;
        end
    end

`ifdef FORMAL
    //  同樣要先約束初始狀態（理由見 fifo_buggy 裡的說明）
    initial assume (!rst_n);

    reg past_valid = 0;
    always @(posedge clk) past_valid <= 1;

    always @(posedge clk) begin
        if (past_valid && rst_n) begin
            assert (count <= (1 << AW));
            assert (!(empty && full));

            //  性質 3：空的時候 count 一定是 0
            assert (!empty || (count == 0));

            //  性質 4：滿的時候 count 一定等於深度
            assert (!full || (count == (1 << AW)));
        end
    end
`endif
endmodule

//  ---- 一般模擬（先看功能）----
//  iverilog -o sim.out 04_formal.v 04_formal_tb.v
//  vvp sim.out
//
//  ---- ★ 形式驗證 ----
//  04_formal.bat
//  或分開跑：
//    sby -f 04_formal_buggy.sby     ← 預期【失敗】，會產生反例波形
//    sby -f 04_formal_fixed.sby     ← 預期【成功】，數學證明通過
