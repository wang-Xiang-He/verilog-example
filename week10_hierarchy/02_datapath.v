// ============================================================
//  W10-2：資料路徑 + 控制器分離        ← 課本 3.7 + 第 10 章
//  重點：★ 這是【所有數位系統的標準架構】，大到 CPU 小到洗衣機都一樣
//
//        資料路徑 Datapath ：負責「算」—— 暫存器、加法器、多工器
//        控制器   Controller：負責「什麼時候算什麼」—— 一台狀態機
//
//        兩者之間只用【控制訊號】和【狀態旗標】溝通：
//
//            ┌────────────┐  控制訊號   ┌────────────┐
//            │ Controller │────────────→│  Datapath  │
//            │   (FSM)    │←────────────│ (暫存器+ALU)│
//            └────────────┘  狀態旗標   └────────────┘
//
//  這個例子做「移位相加乘法器」：用加法和位移算出 a*b，不用乘法器。
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  一、控制器：只有狀態機，一個資料位元都不碰
// ------------------------------------------------------------
module mult_ctrl (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire       cnt_done,      // ← 來自資料路徑的旗標

    output reg        load,          // → 給資料路徑的控制訊號
    output reg        shift_add,
    output reg        busy,
    output reg        done
);
    //  ★ 課本 10.3.4 的狀態編碼；這裡用最單純的二進位編碼
    localparam S_IDLE = 2'd0,
               S_CALC = 2'd1,
               S_DONE = 2'd2;

    reg [1:0] state, next_state;

    //  ---- 三段式寫法第 1 段：狀態暫存器 ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= S_IDLE;
        else        state <= next_state;
    end

    //  ---- 第 2 段：下一個狀態的組合邏輯 ----
    always @(*) begin
        next_state = state;              // ★ 先給預設值，避免 latch
        case (state)
            S_IDLE: if (start)    next_state = S_CALC;
            S_CALC: if (cnt_done) next_state = S_DONE;
            S_DONE:               next_state = S_IDLE;
            default:              next_state = S_IDLE;
        endcase
    end

    //  ---- 第 3 段：輸出的組合邏輯（Moore：只看 state）----
    always @(*) begin
        load      = 1'b0;
        shift_add = 1'b0;
        busy      = 1'b0;
        done      = 1'b0;
        case (state)
            S_IDLE: load      = start;
            S_CALC: begin shift_add = 1'b1; busy = 1'b1; end
            S_DONE: done      = 1'b1;
            default: ;
        endcase
    end
endmodule


// ------------------------------------------------------------
//  二、資料路徑：只有暫存器和運算，一個 if(state) 都沒有
// ------------------------------------------------------------
module mult_datapath #(
    parameter W = 8
) (
    input  wire         clk,
    input  wire         rst_n,

    //  ← 來自控制器
    input  wire         load,
    input  wire         shift_add,

    input  wire [W-1:0] a, b,

    //  → 給控制器
    output wire         cnt_done,
    output wire [2*W-1:0] product
);
    reg [2*W-1:0] acc;         // 累積結果
    reg [W-1:0]   mplier;      // 乘數，每拍往右推一位
    reg [2*W-1:0] mcand;       // 被乘數，每拍往左推一位
    reg [3:0]     cnt;

    //  ★ 旗標往上送給控制器：「我數完 W 次了」
    assign cnt_done = (cnt == W - 1);
    assign product  = acc;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc    <= 0;
            mplier <= 0;
            mcand  <= 0;
            cnt    <= 0;
        end else if (load) begin
            acc    <= 0;
            mplier <= b;
            mcand  <= {{W{1'b0}}, a};
            cnt    <= 0;
        end else if (shift_add) begin
            //  ★ 移位相加：乘數最低位是 1 就把被乘數加進來
            //    這就是小學直式乘法，只是進位制從十進位換成二進位
            if (mplier[0]) acc <= acc + mcand;
            mplier <= mplier >> 1;      // 乘數往右
            mcand  <= mcand  << 1;      // 被乘數往左
            cnt    <= cnt + 1;
        end
    end
endmodule


// ------------------------------------------------------------
//  三、頂層：把控制器和資料路徑接起來
//  ★ 注意頂層【只有接線，沒有任何邏輯】—— 這是好的階層式設計的特徵
// ------------------------------------------------------------
module datapath_top #(
    parameter W = 8
) (
    input  wire           clk,
    input  wire           rst_n,
    input  wire           start,
    input  wire [W-1:0]   a, b,
    output wire [2*W-1:0] product,
    output wire           busy,
    output wire           done
);
    //  控制器 ←→ 資料路徑 之間的線
    wire load, shift_add, cnt_done;

    mult_ctrl u_ctrl (
        .clk(clk), .rst_n(rst_n),
        .start(start),
        .cnt_done(cnt_done),        // ← 旗標上來
        .load(load),                // → 控制訊號下去
        .shift_add(shift_add),
        .busy(busy),
        .done(done)
    );

    mult_datapath #(.W(W)) u_dp (
        .clk(clk), .rst_n(rst_n),
        .load(load),
        .shift_add(shift_add),
        .a(a), .b(b),
        .cnt_done(cnt_done),
        .product(product)
    );
endmodule

//  iverilog -o sim.out 02_datapath.v 02_datapath_tb.v
//  vvp sim.out
//  gtkwave 02_datapath.gtkw
