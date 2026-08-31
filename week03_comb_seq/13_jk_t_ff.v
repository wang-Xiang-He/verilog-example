// ============================================================
//  W3-13：JK 型與 T 型正反器          ← 課本 9.1.3 / 9.1.4
//  重點：D 型是實務上唯一會用的，但 JK/T 一定會考
//        ★ 三種正反器都能互相「兜」出來，本檔把兜法一起示範
// ============================================================
`timescale 1ns / 1ps

module jk_t_ff (
    input  wire clk,
    input  wire rst_n,
    input  wire j, k,
    input  wire t,
    input  wire d,

    output reg  q_jk,        // JK 正反器
    output reg  q_t,         // T 正反器
    output reg  q_d,         // D 正反器（對照組）
    output reg  q_t_from_jk, // 用 JK 兜出 T：把 J 和 K 綁在一起
    output reg  q_jk_from_d  // 用 D 兜出 JK：算好下一個值再餵給 D
);

    // --------------------------------------------------------
    //  JK 正反器（課本 9.1.3）
    //    J K | 下一個 Q
    //    0 0 |  保持
    //    0 1 |  清 0     (reset)
    //    1 0 |  設 1     (set)
    //    1 1 |  ★ 反相   (toggle)  ← JK 最有特色的地方
    //  比 SR 正反器好在：11 這組不再是「禁止」，而是有明確定義
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q_jk <= 1'b0;
        else begin
            case ({j, k})
                2'b00: q_jk <= q_jk;      // 保持
                2'b01: q_jk <= 1'b0;      // 清 0
                2'b10: q_jk <= 1'b1;      // 設 1
                2'b11: q_jk <= ~q_jk;     // ★ 反相
            endcase
        end
    end

    // --------------------------------------------------------
    //  T 型正反器（課本 9.1.4）
    //    T=0 → 保持
    //    T=1 → 反相
    //  ★ 計數器就是一整排 T 正反器串起來的
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q_t <= 1'b0;
        else        q_t <= t ? ~q_t : q_t;
    end

    // --------------------------------------------------------
    //  D 型正反器（對照組，課本 9.1.2）
    //  最單純：下一拍就等於現在的 d
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q_d <= 1'b0;
        else        q_d <= d;
    end

    // --------------------------------------------------------
    //  ★ 用 JK 兜出 T：把 J 和 K 都接到 t
    //    t=0 → JK=00 → 保持；t=1 → JK=11 → 反相。剛好就是 T 的定義
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q_t_from_jk <= 1'b0;
        else begin
            case ({t, t})
                2'b00: q_t_from_jk <= q_t_from_jk;
                2'b11: q_t_from_jk <= ~q_t_from_jk;
                default: q_t_from_jk <= q_t_from_jk;
            endcase
        end
    end

    // --------------------------------------------------------
    //  ★ 用 D 兜出 JK：特徵方程式 Q(next) = J·Q' + K'·Q
    //    這條式子考試很愛考，推導一次就記得了
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q_jk_from_d <= 1'b0;
        else        q_jk_from_d <= (j & ~q_jk_from_d) | (~k & q_jk_from_d);
    end

endmodule

//  iverilog -o sim.out 13_jk_t_ff.v 13_jk_t_ff_tb.v
//  vvp sim.out
//  gtkwave 13_jk_t_ff.gtkw
