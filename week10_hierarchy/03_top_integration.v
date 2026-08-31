// ============================================================
//  W10-3：把前幾週的東西整合成一個系統
//  重點：★ 這是本課程第一個「像產品」的東西
//        每個子模組都是前面某一週學過的，這裡只做一件事：把它們接起來
//
//  系統功能：按鍵計數器
//    按鍵（會彈跳） → 去彈跳 → 邊緣偵測 → 上下數計數器
//                                          ├→ 七段顯示解碼
//                                          └→ 存進 FIFO 當操作記錄
//
//    模組                   出處
//    --------------------------------------------
//    debounce_unit          第 6 週 03_debounce
//    edge_detect            第 3 週（移位暫存器的應用）
//    updown_counter         第 8 週 02_updown
//    seg7_decoder           第 8 週 01_seg7
//    log_fifo               第 9 週 04_fifo
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  子模組 1：去彈跳（第 6 週）
//  用計數器確認訊號連續穩定 N 拍才承認它變了
// ------------------------------------------------------------
module debounce_unit #(
    parameter STABLE = 4              // 為了模擬跑得快，這裡設很小
) (
    input  wire clk,
    input  wire rst_n,
    input  wire noisy,
    output reg  clean
);
    reg [7:0] cnt;
    reg       sync0, sync1;

    //  ★ 先做兩級同步（第 7 週 03_cdc_sync 學的），
    //    按鍵是外部非同步訊號，直接用會有亞穩態風險
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin sync0 <= 0; sync1 <= 0; end
        else        begin sync0 <= noisy; sync1 <= sync0; end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt   <= 0;
            clean <= 0;
        end else if (sync1 == clean) begin
            cnt <= 0;                     // 和目前輸出一樣 → 沒事，計數歸零
        end else if (cnt == STABLE - 1) begin
            clean <= sync1;               // 連續不一樣夠久 → 承認它變了
            cnt   <= 0;
        end else begin
            cnt <= cnt + 1;
        end
    end
endmodule


// ------------------------------------------------------------
//  子模組 2：邊緣偵測（單發脈衝產生器）
//  ★ 沒有這個的話，按著不放會一直加
// ------------------------------------------------------------
module edge_detect (
    input  wire clk,
    input  wire rst_n,
    input  wire sig,
    output wire rise,
    output wire fall
);
    reg prev;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) prev <= 1'b0;
        else        prev <= sig;
    end
    //  現在是 1、上一拍是 0 → 上升緣
    assign rise = sig & ~prev;
    assign fall = ~sig & prev;
endmodule


// ------------------------------------------------------------
//  子模組 3：可預載上下數計數器（第 8 週）
// ------------------------------------------------------------
module updown_counter #(
    parameter W = 4
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         tick,          // 一拍寬的脈衝才動作
    input  wire         up,
    input  wire         load,
    input  wire [W-1:0] load_val,
    output reg  [W-1:0] count
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)      count <= 0;
        else if (load)   count <= load_val;
        else if (tick)   count <= up ? count + 1'b1 : count - 1'b1;
    end
endmodule


// ------------------------------------------------------------
//  子模組 4：七段顯示解碼（第 8 週）
// ------------------------------------------------------------
module seg7_decoder (
    input  wire [3:0] bcd,
    output reg  [6:0] seg               // {g,f,e,d,c,b,a}
);
    always @(*) begin
        case (bcd)
            4'd0: seg = 7'b0111111;
            4'd1: seg = 7'b0000110;
            4'd2: seg = 7'b1011011;
            4'd3: seg = 7'b1001111;
            4'd4: seg = 7'b1100110;
            4'd5: seg = 7'b1101101;
            4'd6: seg = 7'b1111101;
            4'd7: seg = 7'b0000111;
            4'd8: seg = 7'b1111111;
            4'd9: seg = 7'b1101111;
            4'ha: seg = 7'b1110111;
            4'hb: seg = 7'b1111100;
            4'hc: seg = 7'b0111001;
            4'hd: seg = 7'b1011110;
            4'he: seg = 7'b1111001;
            4'hf: seg = 7'b1110001;
            default: seg = 7'b0000000;
        endcase
    end
endmodule


// ------------------------------------------------------------
//  子模組 5：操作記錄 FIFO（第 9 週）
// ------------------------------------------------------------
module log_fifo #(
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
endmodule


// ------------------------------------------------------------
//  頂層：只接線，不寫邏輯
//
//   btn_raw ─→[debounce]─→[edge_detect]─→ tick ─→[updown_counter]─┬→[seg7]─→ seg
//                                                                  └→[fifo]─→ 記錄
// ------------------------------------------------------------
module top_integration (
    input  wire       clk,
    input  wire       rst_n,

    input  wire       btn_raw,       // 會彈跳的按鍵
    input  wire       dir_up,        // 1=上數 0=下數
    input  wire       preset,
    input  wire [3:0] preset_val,

    input  wire       log_rd,

    output wire [3:0] count,
    output wire [6:0] seg,
    output wire       btn_clean,
    output wire       tick,
    output wire [7:0] log_dout,
    output wire       log_empty,
    output wire       log_full,
    output wire [3:0] log_count
);

    debounce_unit #(.STABLE(4)) u_deb (
        .clk(clk), .rst_n(rst_n),
        .noisy(btn_raw), .clean(btn_clean)
    );

    edge_detect u_edge (
        .clk(clk), .rst_n(rst_n),
        .sig(btn_clean), .rise(tick), .fall()      // ★ 用不到的埠可以留空
    );

    updown_counter #(.W(4)) u_cnt (
        .clk(clk), .rst_n(rst_n),
        .tick(tick), .up(dir_up),
        .load(preset), .load_val(preset_val),
        .count(count)
    );

    seg7_decoder u_seg (
        .bcd(count), .seg(seg)
    );

    //  ★ 每次按鍵就把「當時的方向 + 計數值」記一筆
    log_fifo #(.DW(8), .AW(3)) u_log (
        .clk(clk), .rst_n(rst_n),
        .wr(tick), .rd(log_rd),
        .din({3'b0, dir_up, count}),
        .dout(log_dout), .empty(log_empty), .full(log_full), .count(log_count)
    );

endmodule

//  iverilog -o sim.out 03_top_integration.v 03_top_integration_tb.v
//  vvp sim.out
//  gtkwave 03_top_integration.gtkw
