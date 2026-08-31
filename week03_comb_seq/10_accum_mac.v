// ============================================================
//  W3-10：累加器與乘加器             ← 課本 8.1.7 / 8.1.8
//  重點：★ 這是第一個「組合邏輯 + 正反器」合體的電路
//        算的部分用 always @(*)，記的部分用 always @(posedge clk)
// ============================================================
`timescale 1ns / 1ps

module accum_mac (
    input  wire        clk,
    input  wire        rst_n,      // 低準位有效的非同步 reset
    input  wire        en,

    input  wire [7:0]  a, b,

    output reg  [15:0] acc,        // 累加器：acc <= acc + a
    output reg  [15:0] mac,        // 乘加器：mac <= mac + a*b
    output wire [15:0] acc_next,   // 把「下一拍的值」拉出來看（教學用）
    output wire        acc_ovf     // 累加溢位旗標
);

    // --------------------------------------------------------
    //  組合部分：算出「下一拍應該是多少」
    //  ★ 課本 11.4.2 的原則：把「組合指定」和「循序指定」分開寫
    //    好處是這條線可以直接拉到波形上看，除錯快非常多
    // --------------------------------------------------------
    wire [16:0] acc_sum = {1'b0, acc} + {9'b0, a};   // 多一位接溢位
    assign acc_next = acc_sum[15:0];
    assign acc_ovf  = acc_sum[16];

    // --------------------------------------------------------
    //  循序部分：累加器
    //  ★ 累加器 = 一顆加法器 + 一組正反器 + 一條「繞回自己」的線
    //    那條繞回去的線就是它會「記住」的原因
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)   acc <= 16'd0;
        else if (en)  acc <= acc_next;
        // else 不寫 → 保持原值。在【循序】區塊裡這是對的，
        //              跟組合區塊漏 else 生 latch 是兩回事。
    end

    // --------------------------------------------------------
    //  乘加器 MAC (Multiply and Accumulate)
    //  數位訊號處理最常用的一顆電路（FIR 濾波器就是一堆 MAC）
    //  第 12 週會把這顆切成管線
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)   mac <= 16'd0;
        else if (en)  mac <= mac + (a * b);
    end

endmodule

//  iverilog -o sim.out 10_accum_mac.v 10_accum_mac_tb.v
//  vvp sim.out
//  gtkwave 10_accum_mac.gtkw
