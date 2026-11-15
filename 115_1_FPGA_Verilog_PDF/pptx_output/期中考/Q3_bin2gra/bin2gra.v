// bin2gra.v : 二進位碼轉格雷碼（期中考 第 3 題，題目原始程式）
module bin2gra(Gry, Bin);
  parameter length = 8;
  output [length-1:0] Gry;
  input  [length-1:0] Bin;
  reg    [length-1:0] Gry;
  integer i;

  always @(Bin)
    begin
      for (i = 0; i < length - 1; i = i + 1)
        Gry[i] = Bin[i] ^ Bin[i+1];
      Gry[i] = Bin[i];          // 迴圈結束時 i = length-1，最高位元直接照抄
    end
endmodule
