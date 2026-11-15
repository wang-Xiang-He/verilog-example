// bin2gra_test.v : bin2gra 的測試平台（期中考 第 3 題）
// 1. 由 0 掃到 2^length-1，全部輸入都測
// 2. 與標準公式 Gray = Bin ^ (Bin >> 1) 比對
// 3. 額外檢查格雷碼特性：相鄰兩碼只差 1 個位元
`timescale 1ns/1ps
module bin2gra_test;
  parameter length = 8;

  reg  [length-1:0] Bin;
  wire [length-1:0] Gry;
  reg  [length-1:0] Gry_prev;
  integer k, err;

  // 被測電路（UUT）
  bin2gra #(.length(length)) UUT (.Gry(Gry), .Bin(Bin));

  // 計算兩個向量相差幾個位元
  function integer ones;
    input [length-1:0] v;
    integer j;
    begin
      ones = 0;
      for (j = 0; j < length; j = j + 1) ones = ones + v[j];
    end
  endfunction

  initial begin
    err = 0;
    Bin = 0;
    #10 Gry_prev = Gry;
    $display("  Bin       Gry       expected");
    for (k = 0; k < (1 << length); k = k + 1) begin
      Bin = k;
      #10;
      if (k < 8 || k > (1 << length) - 4)
        $display("  %b  %b  %b", Bin, Gry, Bin ^ (Bin >> 1));
      if (Gry !== (Bin ^ (Bin >> 1))) begin
        err = err + 1;
        $display("  ERROR: Bin=%b Gry=%b", Bin, Gry);
      end
      if (k > 0 && ones(Gry ^ Gry_prev) != 1) begin
        err = err + 1;
        $display("  ERROR: adjacent codes differ in more than 1 bit at Bin=%0d", k);
      end
      Gry_prev = Gry;
    end
    if (err == 0) $display("PASS: all %0d inputs correct", 1 << length);
    else          $display("FAIL: %0d errors", err);
    $finish;
  end

endmodule
// 【預期輸出】Gry = Bin ^ (Bin>>1)，例：Bin=0000_0011 → Gry=0000_0010；最後 PASS: all 256 inputs correct
// 【ModelSim 執行指令】 do run.do
