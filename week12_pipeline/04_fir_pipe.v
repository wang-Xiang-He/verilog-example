// ============================================================
//  W12-4：把 FIR 濾波器切成管線
//  重點：★ FIR 是管線最經典的應用 —— 資料一直來、一直算，不會停
//        這種「連續資料流」的場合，管線是標準作法
//
//  4 階 FIR：y[n] = c0*x[n] + c1*x[n-1] + c2*x[n-2] + c3*x[n-3]
//
//  每算一個輸出要 4 次乘法 + 3 次加法。
//  上一週實測過一顆 8x8 乘法器要 158 個 LUT ——
//  四顆全部串在一個時脈週期裡，關鍵路徑會非常長。
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  一、單週期版：四次乘法 + 三次加法全部擠在一拍
// ------------------------------------------------------------
module fir_comb #(
    parameter DW = 8
) (
    input  wire                clk,
    input  wire                rst_n,
    input  wire                vld_in,
    input  wire [DW-1:0]       x,
    input  wire [DW-1:0]       c0, c1, c2, c3,

    output reg  [2*DW+1:0]     y,
    output reg                 vld_out
);
    //  移位暫存器：存最近 4 筆輸入（第 3 週 14_shift_4types 的 SIPO）
    reg [DW-1:0] d0, d1, d2, d3;
    reg          v0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            d0 <= 0; d1 <= 0; d2 <= 0; d3 <= 0; v0 <= 0;
        end else if (vld_in) begin
            d0 <= x;            // 最新的
            d1 <= d0;
            d2 <= d1;
            d3 <= d2;           // 最舊的
            v0 <= 1'b1;
        end else begin
            v0 <= 1'b0;
        end
    end

    //  ★ 關鍵路徑：4 顆乘法器 + 3 層加法，全部在這一拍做完
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y <= 0; vld_out <= 0;
        end else begin
            y <= (d0 * c0) + (d1 * c1) + (d2 * c2) + (d3 * c3);
            vld_out <= v0;
        end
    end
endmodule


// ------------------------------------------------------------
//  二、管線版：切成三級
//     級 1：只做乘法
//     級 2：兩兩相加
//     級 3：最後相加
// ------------------------------------------------------------
module fir_pipe #(
    parameter DW = 8
) (
    input  wire            clk,
    input  wire            rst_n,
    input  wire            vld_in,
    input  wire [DW-1:0]   x,
    input  wire [DW-1:0]   c0, c1, c2, c3,

    output reg  [2*DW+1:0] y,
    output reg             vld_out
);
    //  ---- 移位暫存器（和上面一樣）----
    reg [DW-1:0] d0, d1, d2, d3;
    reg          v0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            d0 <= 0; d1 <= 0; d2 <= 0; d3 <= 0; v0 <= 0;
        end else if (vld_in) begin
            d0 <= x; d1 <= d0; d2 <= d1; d3 <= d2;
            v0 <= 1'b1;
        end else begin
            v0 <= 1'b0;
        end
    end

    //  ---- 級 1：只做乘法，不做加法 ----
    reg [2*DW-1:0] m0, m1, m2, m3;
    reg            v1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m0 <= 0; m1 <= 0; m2 <= 0; m3 <= 0; v1 <= 0;
        end else begin
            m0 <= d0 * c0;
            m1 <= d1 * c1;
            m2 <= d2 * c2;
            m3 <= d3 * c3;
            v1 <= v0;
        end
    end

    //  ---- 級 2：兩兩相加 ----
    reg [2*DW:0] s0, s1;
    reg          v2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s0 <= 0; s1 <= 0; v2 <= 0;
        end else begin
            s0 <= m0 + m1;
            s1 <= m2 + m3;
            v2 <= v1;
        end
    end

    //  ---- 級 3：最後相加 ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y <= 0; vld_out <= 0;
        end else begin
            y       <= s0 + s1;
            vld_out <= v2;
        end
    end

    //  ★ valid 一路跟著：v0 → v1 → v2 → vld_out
endmodule

//  iverilog -o sim.out 04_fir_pipe.v 04_fir_pipe_tb.v
//  vvp sim.out
//  gtkwave 04_fir_pipe.gtkw
//
//  ---- 實測最高時脈 ----
//  04_fir_pipe.bat
