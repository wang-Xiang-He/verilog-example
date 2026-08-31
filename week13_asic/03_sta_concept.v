// ============================================================
//  W13-3：靜態時序分析 (STA) 的觀念
//  重點：★ 「最高時脈」不是量出來的，是【算】出來的
//
//  動態模擬（前面 12 週做的）：餵一組輸入，看輸出對不對
//     → 只驗證你【想得到】的那些輸入組合
//
//  靜態時序分析：不餵任何輸入，直接檢查【每一條路徑】的延遲
//     → 涵蓋【所有】可能，而且幾秒就跑完
//
//  ⚠️ 課本沒有 STA 專章。第 7 週講過 setup/hold，這裡把它組成完整的算式。
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  一條「正反器 → 組合邏輯 → 正反器」的路徑
//  ★ STA 分析的就是這種路徑，一個晶片裡有幾百萬條
//
//     ┌─────┐   Tcq    ┌──────────┐  Tlogic   ┌─────┐
//     │ FF1 │─────────→│ 組合邏輯 │──────────→│ FF2 │
//     └─────┘          └──────────┘           └─────┘
//        ↑                                       ↑
//        └──────────── clk ──────────────────────┘
//
//  要成立的條件（setup 檢查）：
//     Tcq + Tlogic + Tsetup  ≤  時脈週期 - 時脈偏移
//
//  也就是說：資料要在【下一個時脈邊緣來之前】就準備好並穩定住。
// ------------------------------------------------------------
module timing_path #(
    parameter LOGIC_LEVELS = 4        // 中間串幾層邏輯（決定路徑多長）
) (
    input  wire clk,
    input  wire rst_n,
    input  wire d,
    output reg  q
);
    reg  ff1;
    wire chain_out;

    //  起點正反器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) ff1 <= 1'b0;
        else        ff1 <= d;
    end

    //  中間的組合邏輯鏈 —— 層數由參數決定
    //  ★ 層數越多，路徑越長，能跑的時脈越低
    wire [LOGIC_LEVELS:0] chain;
    assign chain[0] = ff1;

    genvar i;
    generate
        for (i = 0; i < LOGIC_LEVELS; i = i + 1) begin : lvl
            //  用 XOR 是因為它是最慢的基本閘（元件庫裡 XOR2 延遲 0.12ns，
            //  是 NOT 的 6 倍）—— 拿來當「長路徑」的示範最有效
            assign chain[i+1] = chain[i] ^ 1'b0;
        end
    endgenerate

    assign chain_out = chain[LOGIC_LEVELS];

    //  終點正反器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= 1'b0;
        else        q <= chain_out;
    end
endmodule


// ------------------------------------------------------------
//  ★ 拿來實測用：三種不同長度的路徑並排
//    綜合 + 佈局繞線之後，可以看到它們的最高時脈確實不一樣
// ------------------------------------------------------------
module sta_demo (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] a, b,

    output reg  [7:0] short_path,      // 短路徑：只有一層邏輯
    output reg  [8:0] medium_path,     // 中路徑：一顆加法器
    output reg [15:0] long_path        // ★ 長路徑：一顆乘法器
);
    reg [7:0] a_r, b_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin a_r <= 0; b_r <= 0; end
        else        begin a_r <= a; b_r <= b; end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            short_path <= 0; medium_path <= 0; long_path <= 0;
        end else begin
            short_path  <= a_r ^ b_r;       // 8 顆 XOR 並排，只有一層
            medium_path <= a_r + b_r;       // 加法器：進位要一路傳過去
            long_path   <= a_r * b_r;       // ★ 乘法器：最長的一條
        end
    end
endmodule



// ------------------------------------------------------------
//  ★ 把三條路徑【拆成獨立模組】，才能分別量出各自的最高時脈
//
//  （上面的 sta_demo 三條都在同一個模組裡，
//    量出來只會是「最慢那條」的數字 ——
//    這本身就是 STA 最重要的一課：
//    ★★ 整個設計的最高時脈，由【最慢的那一條路徑】決定。
//       其他路徑再快都沒用。）
// ------------------------------------------------------------

//  短路徑：8 顆 XOR 並排，只有一層邏輯
module path_short (
    input  wire clk, rst_n,
    input  wire [7:0] a, b,
    output reg  [7:0] y
);
    reg [7:0] ar, br;
    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin ar <= 0; br <= 0; end
        else        begin ar <= a; br <= b; end
    always @(posedge clk or negedge rst_n)
        if (!rst_n) y <= 0; else y <= ar ^ br;
endmodule

//  中路徑：加法器，進位要一路傳過 8 位元
module path_medium (
    input  wire clk, rst_n,
    input  wire [7:0] a, b,
    output reg  [8:0] y
);
    reg [7:0] ar, br;
    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin ar <= 0; br <= 0; end
        else        begin ar <= a; br <= b; end
    always @(posedge clk or negedge rst_n)
        if (!rst_n) y <= 0; else y <= ar + br;
endmodule

//  ★ 長路徑：乘法器，159 個 LUT 串在一起
module path_long (
    input  wire clk, rst_n,
    input  wire [7:0] a, b,
    output reg  [15:0] y
);
    reg [7:0] ar, br;
    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin ar <= 0; br <= 0; end
        else        begin ar <= a; br <= b; end
    always @(posedge clk or negedge rst_n)
        if (!rst_n) y <= 0; else y <= ar * br;
endmodule

//  ---- 模擬 ----
//  iverilog -o sim.out 03_sta_concept.v 03_sta_concept_tb.v
//  vvp sim.out
//
//  ---- 實測各條路徑的最高時脈 ----
//  03_sta_concept.bat
