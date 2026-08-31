// ============================================================
//  W3-14：四種移位暫存器             ← 課本 9.2.1 ~ 9.2.4
//  重點：★ 「串」和「並」講的是【資料怎麼進、怎麼出】
//        串 = 一次一位、分很多拍   /   並 = 全部一起、一拍搞定
// ============================================================
`timescale 1ns / 1ps

module shift_4types #(
    parameter W = 8
) (
    input  wire         clk,
    input  wire         rst_n,

    input  wire         sin,        // 串列輸入（一次一位）
    input  wire [W-1:0] pin,        // 並列輸入（一次全部）
    input  wire         load,       // 1 = 並列載入，0 = 串列移位
    input  wire         en,

    // 9.2.1 SISO：串進串出
    output wire         siso_out,
    // 9.2.2 SIPO：串進並出  ← 序列埠收資料就是這個
    output wire [W-1:0] sipo_out,
    // 9.2.3 PISO：並進串出  ← 序列埠送資料就是這個
    output wire         piso_out,
    // 9.2.4 PIPO：並進並出  ← 其實就是一組普通的暫存器
    output wire [W-1:0] pipo_out
);

    // --------------------------------------------------------
    //  9.2.1  SISO：串進串出
    //  一位一位推進去，W 拍之後從另一端一位一位出來
    //  ★ 它的用途就是「把訊號延遲 W 拍」
    // --------------------------------------------------------
    reg [W-1:0] siso_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)      siso_r <= {W{1'b0}};
        else if (en)     siso_r <= {siso_r[W-2:0], sin};   // 左移，右邊補 sin
    end
    assign siso_out = siso_r[W-1];       // 只把最高位拉出去 → 串列輸出

    // --------------------------------------------------------
    //  9.2.2  SIPO：串進並出
    //  暫存器內容【整組】拉出去
    //  ★ UART 接收端就是這個：一位一位收，收滿 8 位一次交給 CPU
    // --------------------------------------------------------
    reg [W-1:0] sipo_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)      sipo_r <= {W{1'b0}};
        else if (en)     sipo_r <= {sipo_r[W-2:0], sin};
    end
    assign sipo_out = sipo_r;            // ★ 跟 SISO 唯一的差別就在這一行

    // --------------------------------------------------------
    //  9.2.3  PISO：並進串出
    //  load=1 一次吃進 W 位元，然後一拍吐一位
    //  ★ UART 發送端就是這個：CPU 給 8 位，它一位一位送出去
    // --------------------------------------------------------
    reg [W-1:0] piso_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)      piso_r <= {W{1'b0}};
        else if (load)   piso_r <= pin;                    // 並列載入
        else if (en)     piso_r <= {piso_r[W-2:0], 1'b0};  // 之後每拍往左推
    end
    assign piso_out = piso_r[W-1];

    // --------------------------------------------------------
    //  9.2.4  PIPO：並進並出
    //  ★ 說穿了就是一組普通的暫存器，根本沒有「移位」
    //    課本把它放在移位暫存器這節，是為了把四種組合列滿
    // --------------------------------------------------------
    reg [W-1:0] pipo_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)      pipo_r <= {W{1'b0}};
        else if (load)   pipo_r <= pin;
    end
    assign pipo_out = pipo_r;

endmodule

//  iverilog -o sim.out 14_shift_4types.v 14_shift_4types_tb.v
//  vvp sim.out
//  gtkwave 14_shift_4types.gtkw
