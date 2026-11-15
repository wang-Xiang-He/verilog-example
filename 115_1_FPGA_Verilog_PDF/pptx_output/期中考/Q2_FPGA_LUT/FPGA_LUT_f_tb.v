// FPGA_LUT_f_tb.v : 以原始布林式比對 LUT 電路（16 種輸入全測）
`timescale 1ns/1ps
module FPGA_LUT_f_tb;
  reg  x1, x2, x3, x4;
  wire f;
  wire f_ref = ((x1 | x2) & ~x3) | (x1 & ~x3) | (~x1 & ~x4);
  integer k, err;

  FPGA_LUT_f UUT (.f(f), .x1(x1), .x2(x2), .x3(x3), .x4(x4));

  initial begin
    err = 0;
    $display("x1 x2 x3 x4 | f  f_ref");
    for (k = 0; k < 16; k = k + 1) begin
      {x1, x2, x3, x4} = k;
      #10;
      $display(" %b  %b  %b  %b | %b    %b", x1, x2, x3, x4, f, f_ref);
      if (f !== f_ref) err = err + 1;
    end
    if (err == 0) $display("PASS: LUT circuit == f for all 16 inputs");
    else          $display("FAIL: %0d mismatches", err);
    $finish;
  end
endmodule
// 【預期輸出】f 為 1 的輸入（x1x2x3x4）：0000,0010,0100,0110,0101,1000,1001,1100,1101
// 【ModelSim 執行指令】 do run.do
