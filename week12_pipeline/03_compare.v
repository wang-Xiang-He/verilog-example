// ============================================================
//  W12-3：兩顆乘法器並排跑，直接對照
//  重點：★ 同樣的輸入同時餵給兩顆，看它們的答案什麼時候各自出來
//        波形上會非常清楚：管線版晚 2 拍，但兩邊都是每拍出一筆
// ============================================================
`timescale 1ns / 1ps

module compare_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        vld_in,
    input  wire [7:0]  a, b,

    output wire [15:0] p_comb,
    output wire        v_comb,
    output wire [15:0] p_pipe,
    output wire        v_pipe
);

    //  ★ 兩顆吃【完全一樣】的輸入
    mult_comb  u_comb (
        .clk(clk), .rst_n(rst_n), .vld_in(vld_in),
        .a(a), .b(b), .p(p_comb), .vld_out(v_comb)
    );

    mult_pipe3 u_pipe (
        .clk(clk), .rst_n(rst_n), .vld_in(vld_in),
        .a(a), .b(b), .p(p_pipe), .vld_out(v_pipe)
    );

endmodule

//  ---- 模擬（要三個檔一起編）----
//  iverilog -o sim.out 01_mult_comb.v 02_mult_pipe3.v 03_compare.v 03_compare_tb.v
//  vvp sim.out
//  gtkwave 03_compare.gtkw
//
//  ---- 實測最高時脈 ----
//  03_compare.bat
