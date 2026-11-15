// TwosComp16.v : 16 位元 2 的補數（期中考 第 5 題 (C)）
// 做法與 (A) 相同：找出「最低位的 1」，該位元（含）以下保持不變，以上全部反相。
// 例：0000_0000_0110_1000 -> 1111_1111_1001_1000
// 使用 casez（'?' 為 don't care；若輸入出現 x 不會被誤判成匹配，比 casex 安全）
module TwosComp16 (In_Data, Out_Data);
  input  [15:0] In_Data;
  output [15:0] Out_Data;
  reg    [15:0] Out_Data;

  always @(In_Data)
    casez (In_Data)
      16'b???????????????1: Out_Data = In_Data ^ 16'hfffe;
      16'b??????????????10: Out_Data = In_Data ^ 16'hfffc;
      16'b?????????????100: Out_Data = In_Data ^ 16'hfff8;
      16'b????????????1000: Out_Data = In_Data ^ 16'hfff0;
      16'b???????????10000: Out_Data = In_Data ^ 16'hffe0;
      16'b??????????100000: Out_Data = In_Data ^ 16'hffc0;
      16'b?????????1000000: Out_Data = In_Data ^ 16'hff80;
      16'b????????10000000: Out_Data = In_Data ^ 16'hff00;
      16'b???????100000000: Out_Data = In_Data ^ 16'hfe00;
      16'b??????1000000000: Out_Data = In_Data ^ 16'hfc00;
      16'b?????10000000000: Out_Data = In_Data ^ 16'hf800;
      16'b????100000000000: Out_Data = In_Data ^ 16'hf000;
      16'b???1000000000000: Out_Data = In_Data ^ 16'he000;
      16'b??10000000000000: Out_Data = In_Data ^ 16'hc000;
      16'b?100000000000000: Out_Data = In_Data ^ 16'h8000;
      16'b1000000000000000: Out_Data = In_Data ^ 16'h0000;
      default:              Out_Data = In_Data;           // In_Data = 0 -> 0
    endcase
endmodule

// 另一種寫法（同樣結果）：反相後加 1
//   assign Out_Data = ~In_Data + 16'd1;
