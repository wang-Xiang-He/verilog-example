// ============================================================
//  W13-1：綜合成通用邏輯閘網表          ← 課本 1.2 半訂製 IC 設計流程
//  重點：★ ASIC 和 FPGA 最大的差別在【綜合的目標】
//
//        FPGA：目標是「查表 LUT」—— 元件是固定的，你只能填內容
//        ASIC：目標是「標準元件庫」—— 從幾百種閘裡面挑，挑完排在晶片上
//
//  本檔用同一份設計，分別綜合成兩種目標，看差別。
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  一、全加器（最小的例子，看得清楚）
// ------------------------------------------------------------
module fa (
    input  wire a, b, cin,
    output wire sum, cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule


// ------------------------------------------------------------
//  二、4 位元加法器
// ------------------------------------------------------------
module adder4 (
    input  wire [3:0] a, b,
    input  wire       cin,
    output wire [3:0] sum,
    output wire       cout
);
    wire [4:0] c;
    assign c[0] = cin;
    assign cout = c[4];

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : slice
            fa u (.a(a[i]), .b(b[i]), .cin(c[i]), .sum(sum[i]), .cout(c[i+1]));
        end
    endgenerate
endmodule


// ------------------------------------------------------------
//  三、有正反器的東西：4 位元計數器
//  ★ 用它來看「一顆正反器在 ASIC 上有多貴」
// ------------------------------------------------------------
module counter4 (
    input  wire       clk,
    input  wire       rst_n,
    output reg  [3:0] q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= 4'd0;
        else        q <= q + 4'd1;
    end
endmodule


// ------------------------------------------------------------
//  四、一顆小 ALU（比較有份量的東西）
// ------------------------------------------------------------
module alu4 (
    input  wire [3:0] a, b,
    input  wire [1:0] op,
    output reg  [3:0] y
);
    always @(*) begin
        case (op)
            2'd0: y = a + b;
            2'd1: y = a - b;
            2'd2: y = a & b;
            2'd3: y = a ^ b;
        endcase
    end
endmodule

//  ---- 模擬 ----
//  iverilog -o sim.out 01_generic_synth.v 01_generic_synth_tb.v
//  vvp sim.out
//
//  ---- ASIC 流程 ----
//  01_generic_synth.bat    綜合成通用閘
//  02_liberty_map.bat      映射到標準元件庫
