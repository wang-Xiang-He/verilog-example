// ============================================================
//  W2-1：向量與位元切片
//  重點：一條 8 位元的匯流排，可以整條看，也可以拆開來看
// ============================================================
`timescale 1ns / 1ps

module vectors (
    input  wire [7:0] data,      // 8 條線綁成一束
    output wire [3:0] high,      // 上半 4 位元
    output wire [3:0] low,       // 下半 4 位元
    output wire       msb,       // 最高位（第 7 位）
    output wire       lsb,       // 最低位（第 0 位）
    output wire [2:0] middle     // 中間三位（第 5,4,3 位）
);

    assign high   = data[7:4];   // 切片：取第 7 到第 4 位
    assign low    = data[3:0];
    assign msb    = data[7];     // 取單一位元不用冒號
    assign lsb    = data[0];
    assign middle = data[5:3];

endmodule

//iverilog -o sim.out 01_vectors.v 01_vectors_tb.v
//vvp sim.out
//gtkwave 01_vectors.gtkw