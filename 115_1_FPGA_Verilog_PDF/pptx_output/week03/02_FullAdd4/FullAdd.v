`timescale 1ns/1ps

// =====================================================================
// FullAdd：1 位元全加器（Full Adder）
// =====================================================================
module FullAdd (
    input  a,
    input  b,
    input  Carry_In,
    output Sum,
    output Carry_Out
);
    // a + b + Carry_In 最大為 3（2'b11）
    // {Carry_Out, Sum}：用連結運算子把兩個 1 位元訊號接成 2 位元
    //   高位元 = 進位（MSB，Most Significant Bit）、低位元 = 和（LSB，Least Significant Bit）
    assign {Carry_Out, Sum} = a + b + Carry_In;
endmodule
