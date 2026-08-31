// ============================================================
//  W11-2：不能合成的語法               ← 課本 4.1（PDF p.145-152）
//  重點：★ 模擬跑得過 ≠ 做得出電路
//        本檔把「只能模擬」的寫法集中起來，跑一次就記得了
//
//  課本 4.1 把不能合成的東西分成四類：
//    4.1.1 敘述     initial / #延遲 / $系統任務 / forever / wait / fork-join
//    4.1.2 運算子   === / !== （因為硬體上沒有「x」和「z」這種值可以比）
//    4.1.3 邏輯閘   pullup / pulldown / tran / rtran ...
//    4.1.4 其他     force / release / real 型別 / 階層式路徑
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  ✅ 這顆【可以】合成 —— 對照組
// ------------------------------------------------------------
module good_design (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] d,
    output reg  [3:0] q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= 4'd0;
        else        q <= d;
    end
endmodule


// ------------------------------------------------------------
//  ❌ 這顆【不能】合成 —— 四類問題全在裡面
//     模擬完全跑得動，但 yosys 會報錯或默默忽略
// ------------------------------------------------------------
module bad_design (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] d,
    output reg  [3:0] q,
    output reg  [3:0] q_delay,
    output reg        is_unknown
`ifdef SIM_ONLY
    ,
    output real       measured        // 4.1.4 real 型別不能合成
`endif
);

    //  ★ 為什麼 real 要用 `ifdef 包起來？
    //    因為 Yosys 連【讀都讀不進去】—— 它會在 read_verilog 階段就
    //    報 "syntax error, unexpected TOK_REAL" 直接停掉。
    //    那樣後面其他的示範就全部跑不到了，所以把它隔開。
    //
    //    這也順便示範了實務上的標準作法：
    //      只給模擬看的東西，用 `ifdef 包起來。
    //    模擬時 iverilog -DSIM_ONLY，綜合時不加，工具就看不到那段。

    // --------------------------------------------------------
    //  ❌ 問題 1（課本 4.1.1）：initial
    //  硬體【沒有「開機時執行一次」這回事】。
    //  電源一來，正反器的值是不確定的，要靠 reset 才有確定值。
    //  ⚠️ 例外：FPGA 的正反器有初始值機制，所以 yosys 對
    //     always @(posedge clk) 外的 initial 有時會接受；
    //     但 ASIC 一定不行，而且這是不可攜的寫法。
    // --------------------------------------------------------
    initial begin
        q          = 4'd7;
        q_delay    = 4'd0;
        is_unknown = 1'b0;
`ifdef SIM_ONLY
        measured   = 0.0;
`endif
    end

    // --------------------------------------------------------
    //  ❌ 問題 2（課本 4.1.1）：# 延遲
    //  「等 3 奈秒」在硬體上沒有意義 ——
    //  真實電路的延遲是由閘和線決定的，不是你講了算。
    //  綜合工具會【直接忽略】它，於是模擬和實際電路行為不一樣。
    // --------------------------------------------------------
    always @(posedge clk) begin
        #3 q_delay <= d;         // ← 綜合時 #3 會被丟掉
    end

    // --------------------------------------------------------
    //  ❌ 問題 3（課本 4.1.2）：=== 和 !==
    //  這兩個運算子會去比較 x 和 z。
    //  但真實電路裡【沒有 x 這種電位】—— 只有高電位和低電位。
    //  所以硬體上根本做不出「判斷這條線是不是 x」的電路。
    // --------------------------------------------------------
    always @(*) begin
        is_unknown = (d === 4'bxxxx);
    end

    // --------------------------------------------------------
    //  ❌ 問題 4（課本 4.1.4）：real 型別
    //  硬體只有位元，沒有浮點數。要小數就用第 2 週學的定點數。
    // --------------------------------------------------------
`ifdef SIM_ONLY
    always @(posedge clk) begin
        measured = $realtime;    // $realtime 也是系統任務，同樣不能合成
    end
`endif

    // --------------------------------------------------------
    //  ❌ 問題 5（課本 4.1.1）：$系統任務
    //  $display / $monitor / $finish 都只存在於模擬器裡
    // --------------------------------------------------------
    always @(posedge clk) begin
        if (d == 4'hF) $display("      [來自 bad_design 內部] d 是 F");
    end

endmodule


// ------------------------------------------------------------
//  ⚠️ 這顆語法上「可以合成」，但綜合出來的東西【不是你想的那樣】
//     —— 比語法錯誤更危險，因為工具不會報錯
// ------------------------------------------------------------
module subtle_trap (
    input  wire       clk,
    input  wire       en,
    input  wire [3:0] d,
    output reg  [3:0] latched,     // ⚠️ 會生 latch
    output reg  [3:0] wrong_ff,    // ⚠️ 會塌成 1 顆
    output reg  [3:0] q1, q2, q3
);

    //  ⚠️ 陷阱 1：漏 else → latch（第 3 週 02_latch_trap）
    always @(*) begin
        if (en) latched = d;
        // 沒有 else
    end

    //  ⚠️ 陷阱 2：時脈區塊用阻塞 = → 三顆正反器塌成一顆
    //     （第 3 週 04_blocking_vs_non）
    always @(posedge clk) begin
        q1 = d;
        q2 = q1;
        q3 = q2;
    end

    //  ⚠️ 陷阱 3：兩個 always 驅動同一個變數 → 綜合工具直接報錯
    //     （這個是真的會擋下來，算是幸運的）
    always @(posedge clk) wrong_ff <= d;
    // always @(posedge clk) wrong_ff <= ~d;   ← 取消註解就會爆

endmodule

//  ---- 模擬：全部都跑得動（★ 要加 -DSIM_ONLY）----
//  iverilog -DSIM_ONLY -o sim.out 02_unsynth.v 02_unsynth_tb.v
//  vvp sim.out
//
//  ---- 綜合：見真章 ----
//  yosys -s 02_unsynth.ys
