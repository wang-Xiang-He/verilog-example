// ============================================================
//  W3-11：三態閘與 inout 雙向埠       ← 課本 8.1.9 / 8.1.10
//  重點：★ z（高阻抗）不是 0 也不是 1，是「我放手不驅動這條線」
//        這是唯一可以讓「多個輸出接同一條線」而不燒掉的方法
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  一、單純的三態閘
// ------------------------------------------------------------
module tristate_buf (
    input  wire [7:0] din,
    input  wire       oe,        // output enable
    output wire [7:0] dout
);
    //  oe=1 → 把 din 送出去
    //  oe=0 → 送 z，等於把這顆閘的輸出腳從線上「拔掉」
    assign dout = oe ? din : 8'bz;
endmodule


// ------------------------------------------------------------
//  二、掛在共用匯流排上的一個裝置
//     真實世界的 SRAM、I2C、SD 卡都是這樣接的
// ------------------------------------------------------------
module bus_device #(
    parameter [7:0] MY_DATA = 8'h00
) (
    inout  wire [7:0] bus,       // ★ inout：同一組腳位既能讀也能寫
    input  wire       drive,     // 1 = 我要說話，0 = 我閉嘴聽別人講
    output wire [7:0] seen       // 我在這條線上「聽到」什麼
);
    //  ★ inout 的標準寫法就是這一行：三態閘
    assign bus  = drive ? MY_DATA : 8'bz;

    //  要讀的時候直接讀就好，不用特別做什麼
    assign seen = bus;
endmodule


// ------------------------------------------------------------
//  三、把兩個裝置掛上同一條匯流排
// ------------------------------------------------------------
module tristate_inout (
    input  wire       drive_a,
    input  wire       drive_b,
    output wire [7:0] bus,
    output wire [7:0] a_seen,
    output wire [7:0] b_seen,

    //  順便示範單純的三態閘
    input  wire [7:0] tb_din,
    input  wire       tb_oe,
    output wire [7:0] tb_dout
);

    bus_device #(.MY_DATA(8'hAA)) dev_a (
        .bus(bus), .drive(drive_a), .seen(a_seen)
    );

    bus_device #(.MY_DATA(8'h55)) dev_b (
        .bus(bus), .drive(drive_b), .seen(b_seen)
    );

    tristate_buf tbuf (.din(tb_din), .oe(tb_oe), .dout(tb_dout));

endmodule

//  iverilog -o sim.out 11_tristate_inout.v 11_tristate_inout_tb.v
//  vvp sim.out
//  gtkwave 11_tristate_inout.gtkw
