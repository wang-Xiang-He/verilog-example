// ============================================================
//  期末專題 第 2 題：簡易 8-bit CPU（4 個指令）
//  難度：★★★   考的是：第 6、9、10 週（狀態機 + 記憶體 + 階層式設計）
//  配分：100 分
// ============================================================
`timescale 1ns / 1ps

//  ============================================================
//  規格
//  ============================================================
//
//  這是一台最小的馮紐曼架構 CPU：
//
//     ┌──────────────┐  控制訊號  ┌────────────────────┐
//     │  控制器 FSM   │──────────→│  資料路徑           │
//     │ FETCH/DECODE │←──────────│  PC / ACC / 記憶體  │
//     │   /EXECUTE   │  指令      └────────────────────┘
//     └──────────────┘
//
//  ★ 這就是第 10 週 02_datapath 的架構放大版。
//
//  ------------------------------------------------------------
//  指令格式（8 位元）
//
//      7  6 | 5  4  3  2  1  0
//     ------+------------------
//      opcode        addr
//
//  ------------------------------------------------------------
//  指令集
//
//     opcode  助記符      動作
//     ------------------------------------------------------
//      00     LDA addr    ACC <- MEM[addr]
//      01     ADD addr    ACC <- ACC + MEM[addr]
//      10     STA addr    MEM[addr] <- ACC
//      11     JMP addr    PC  <- addr
//
//  ------------------------------------------------------------
//  記憶體
//     單一個 64 x 8 的記憶體，程式和資料放在一起（馮紐曼架構）
//     測試平台會用 $readmemh 從 program.hex 載入
//
//  ------------------------------------------------------------
//  執行流程
//     FETCH   : ir <- mem[pc]，pc <- pc + 1
//     DECODE  : 解出 opcode 和 addr（★ 讀記憶體要一拍，這裡剛好等它）
//     EXECUTE : 依 opcode 動作。JMP 的話 pc <- addr
//     → 回到 FETCH
//
//     ⚠️ 注意 JMP：FETCH 階段已經把 pc 加過 1 了，
//        EXECUTE 要【直接覆蓋】成 addr，不是再加。
//  ============================================================

module cpu (
    input  wire       clk,
    input  wire       rst_n,

    //  ---- 給測試平台觀察用的輸出 ----
    output wire [5:0] pc_out,
    output wire [7:0] acc_out,
    output wire [7:0] ir_out,
    output wire [1:0] state_out,
    output wire       halted,       // 執行到 JMP 跳回自己 → 停住

    //  ---- 測試平台載入程式用 ----
    input  wire       load_en,
    input  wire [5:0] load_addr,
    input  wire [7:0] load_data,

    //  ---- 測試平台檢查結果用 ----
    input  wire [5:0] peek_addr,
    output wire [7:0] peek_data
);

    // ========================================================
    //  ★★★ 在這裡寫你的答案 ★★★
    // ========================================================
    //
    //  ---- 你需要宣告的東西 ----
    //    reg [7:0] mem [0:63];     記憶體
    //    reg [5:0] pc;             程式計數器
    //    reg [7:0] acc;            累加器
    //    reg [7:0] ir;             指令暫存器
    //    reg [1:0] state;          狀態機
    //
    //  ---- 狀態編碼（測試平台會檢查，請照這個用）----
    //    localparam S_FETCH = 2'd0, S_DECODE = 2'd1, S_EXEC = 2'd2;
    //
    //  ---- 操作碼 ----
    //    localparam OP_LDA = 2'b00, OP_ADD = 2'b01,
    //               OP_STA = 2'b10, OP_JMP = 2'b11;
    //
    //  ---- 提示 ----
    //
    //  1. 載入程式：load_en=1 時 mem[load_addr] <= load_data
    //     （這時候 CPU 不要執行，測試平台會壓著 rst_n）
    //
    //  2. peek_data 是【非同步讀】：assign peek_data = mem[peek_addr];
    //     這只是給測試平台看的，真實 CPU 不會有這個埠
    //
    //  3. halted：偵測「JMP 跳到自己這一行」就代表程式結束
    //     提示：EXECUTE 階段，opcode==OP_JMP 而且 addr == pc-1
    //
    //  4. ⚠️ 最容易錯的地方：
    //     - FETCH 已經 pc+1 了，JMP 要【覆蓋】不是再加
    //     - STA 寫進去的是 acc，不是 mem[addr]
    //     - ADD 是 acc + mem[addr]，順序別搞反（雖然加法可交換，
    //       但下次改成 SUB 就會錯）

    assign pc_out    = 6'd0;      // ← 補完後刪掉這些預設值
    assign acc_out   = 8'd0;
    assign ir_out    = 8'd0;
    assign state_out = 2'd0;
    assign halted    = 1'b0;
    assign peek_data = 8'd0;

endmodule

//  ---- 怎麼跑 ----
//  iverilog -o sim.out 02_cpu.v 02_cpu_tb.v
//  echo %ERRORLEVEL%
//  vvp sim.out
//
//  ---- 看解答 ----
//  _answers\02_cpu.v
