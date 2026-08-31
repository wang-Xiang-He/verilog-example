// ============================================================
//  W2-5：四值邏輯 0 / 1 / x / z
//  重點：★ 這兩個怪東西是你以後除錯最重要的線索 ★
// ============================================================
`timescale 1ns / 1ps

//   0 = 低電位
//   1 = 高電位
//   x = 不知道（模擬器算不出來 / 還沒被設定過）
//   z = 高阻抗（這條線根本沒接東西，浮空）

module xz (
    input  wire       data,
    input  wire       enable,
    input  wire       undriven_in,   // 測試檔故意不接
    output wire       tri_out,       // 三態輸出：會產生 z
    output wire [3:0] from_undriven  // 從沒被驅動的線來的：會是 x 或 z
);

    // 三態緩衝器：enable=1 才輸出，否則把線放掉變成 z
    assign tri_out = enable ? data : 1'bz;

    // 只要運算中有 x，結果就會被「傳染」成 x
    assign from_undriven = {4{undriven_in}};

endmodule
//iverilog -o sim.out 05_xz.v 05_xz_tb.v
//vvp sim.out
//gtkwave 05_xz.gtkw
