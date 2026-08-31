// ============================================================
//  W2-3：串接 {} 與複製 {n{}}
//  重點：大括號在 Verilog 裡是「把線黏在一起」，不是程式區塊
// ============================================================
`timescale 1ns / 1ps

module concat (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [7:0] joined,      // {a, b}      把兩束線接成一束
    output wire [7:0] swapped,     // {b, a}      對調
    output wire [7:0] repeated,    // {2{a}}      複製兩次
    output wire [3:0] reversed,    // 把 a 前後顛倒
    output wire [7:0] mixed,       // 混合玩法
    output wire [7:0] sign_ext     // 符號延伸
);

    assign joined   = {a, b};              // a 在高位，b 在低位
    assign swapped  = {b, a};
    assign repeated = {2{a}};              // 等於 {a, a}
    assign reversed = {a[0], a[1], a[2], a[3]};
    assign mixed    = {a[3:2], 2'b01, b};  // 可以夾常數進去
    assign sign_ext = {{4{a[3]}}, a};      // 把最高位複製 4 次接在前面
                                           // 這是「有號數」延伸的標準寫法
endmodule
//iverilog -o sim.out 03_concat.v 03_concat_tb.v
//vvp sim.out
//gtkwave 03_concat.gtkw
