`timescale 1ns/1ps

// =====================================================================
// FullAdd4：4 位元漣波進位加法器（Ripple Carry Adder）
//   由 4 個 FullAdd 串接：前一級的 Carry_Out 接到下一級的 Carry_In
//   「漣波」= 進位像水波一樣一級一級往上傳
//   ※ 需要 FullAdd.v 一起編譯
// =====================================================================
module FullAdd4 (
    input  [3:0] a, b,          // [3:0] = 4 位元向量，a[3] 最高位、a[0] 最低位
    input        Carry_In,
    output [3:0] Sum,
    output       Carry_Out
);
    // 內部串接用的進位訊號（講義投影片漏寫了這行，建議補上）
    wire Carry_Out1, Carry_Out2, Carry_Out3;

    // 實例化 4 個 FullAdd（講義稱為「別名」fa0~fa3）
    // 「依順序（in order）」對應埠：順序必須和 FullAdd 的 (a, b, Carry_In, Sum, Carry_Out) 一致
    FullAdd fa0 (a[0], b[0], Carry_In,   Sum[0], Carry_Out1);
    FullAdd fa1 (a[1], b[1], Carry_Out1, Sum[1], Carry_Out2);
    FullAdd fa2 (a[2], b[2], Carry_Out2, Sum[2], Carry_Out3);
    FullAdd fa3 (a[3], b[3], Carry_Out3, Sum[3], Carry_Out);
endmodule
