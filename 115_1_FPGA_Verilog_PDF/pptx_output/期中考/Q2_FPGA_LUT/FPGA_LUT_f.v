// FPGA_LUT_f.v : 期中考 第 2 題
// f = (x1 + x2)·x3' + x1·x3' + x1'·x4'
//   = (x1 + x2)·x3' + x1'·x4'          （x1·x3' 被 (x1+x2)·x3' 吸收）
// 依講義第一章第 36 頁「被程式化 FPGA」的 2 輸入 LUT 架構實現：
//   LUT1 : f1 = x1 + x2        真值表(00,01,10,11) = 0 1 1 1
//   LUT2 : f2 = f1 · x3'       真值表(00,01,10,11) = 0 0 1 0
//   LUT3 : f3 = x1' · x4'      真值表(00,01,10,11) = 1 0 0 0
//   LUT4 : f  = f2 + f3        真值表(00,01,10,11) = 0 1 1 1

// 2 輸入查表（LUT）：4 個記憶格 + 4 選 1 多工器
module LUT2 #(parameter [3:0] INIT = 4'b0000) (output y, input a, input b);
  // INIT[{a,b}] 即為輸出；INIT 位元 3..0 對應 ab = 11,10,01,00
  assign y = INIT[{a, b}];
endmodule

module FPGA_LUT_f (output f, input x1, x2, x3, x4);
  wire f1, f2, f3;
  //                ab: 11 10 01 00
  LUT2 #(4'b1110) LUT1 (.y(f1), .a(x1), .b(x2));   // f1 = x1 + x2
  LUT2 #(4'b0100) LUT2_ (.y(f2), .a(f1), .b(x3));  // f2 = f1 · x3'
  LUT2 #(4'b0001) LUT3 (.y(f3), .a(x1), .b(x4));   // f3 = x1'· x4'
  LUT2 #(4'b1110) LUT4 (.y(f),  .a(f2), .b(f3));   // f  = f2 + f3
endmodule
