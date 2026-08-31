// ============================================================
//  W12-1：單週期乘法器（管線的對照組）
//  重點：★ 一拍算完 —— 聽起來很棒，但「一拍」要多長？
//        整條運算鏈越長，時脈就得放得越慢。這就是要切管線的理由。
//
//  ⚠️ 課本沒有管線專章。最接近的是 11.1 資源共用和 7.4.3 乘法運算。
//     本週內容主要參考業界作法。
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  8x8 → 16 位元乘法器，輸入輸出都上正反器
//
//  ★ 為什麼輸入輸出要上正反器？
//    因為要比較「最高時脈」時，必須量【正反器到正反器】之間的路徑。
//    如果輸入直接吃外面的線，量到的是外面的延遲，比較就不公平。
//    這是做時序比較的標準作法。
//
//         din_a ─→[FF]─┐
//                      ├─→ 【一整顆乘法器】─→[FF]─→ dout
//         din_b ─→[FF]─┘
//                       ↑
//                 全部延遲都在這一段
// ------------------------------------------------------------
module mult_comb (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        vld_in,
    input  wire [7:0]  a, b,

    output reg  [15:0] p,
    output reg         vld_out
);
    reg [7:0] a_r, b_r;
    reg       v_r;

    //  第 1 段：把輸入抓進來
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_r <= 8'd0; b_r <= 8'd0; v_r <= 1'b0;
        end else begin
            a_r <= a; b_r <= b; v_r <= vld_in;
        end
    end

    //  第 2 段：★ 整顆乘法器擠在【一個時脈週期】裡做完
    //           上一週實測過：8x8 乘法器要 158 個 LUT，
    //           訊號要一路穿過這 158 個 LUT 才會穩定下來。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p <= 16'd0; vld_out <= 1'b0;
        end else begin
            p       <= a_r * b_r;      // ← 關鍵路徑就是這一行
            vld_out <= v_r;
        end
    end

endmodule

//  ---- 延遲 (latency)：2 拍（進去到出來）
//  ---- 吞吐量 (throughput)：每拍 1 筆
//  ---- 最高時脈：受限於那一整顆乘法器的延遲 → 低

//  iverilog -o sim.out 01_mult_comb.v 01_mult_comb_tb.v
//  vvp sim.out
//  gtkwave 01_mult_comb.gtkw
