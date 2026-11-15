// case_compare.v : 期中考 第 5 題 (A)(B)
// 把題目的 (A)「? 型樣」與 (B)「x 型樣」分別用 case / casez / casex 寫成 6 個模組，
// 用同一個測試平台比較哪一種寫法才能得到正確結果（8 位元 2 的補數）。

// ---------------- (A) 以 ? 撰寫 ----------------
module A_case (input [7:0] In_Data, output reg [7:0] Out_Data);
  always @(In_Data)
    case (In_Data)
      8'b???????1: Out_Data = In_Data ^ 8'hfe;
      8'b??????10: Out_Data = In_Data ^ 8'hfc;
      8'b?????100: Out_Data = In_Data ^ 8'hf8;
      8'b????1000: Out_Data = In_Data ^ 8'hf0;
      8'b???10000: Out_Data = In_Data ^ 8'he0;
      8'b??100000: Out_Data = In_Data ^ 8'hc0;
      8'b?1000000: Out_Data = In_Data ^ 8'h80;
      8'b10000000: Out_Data = In_Data ^ 8'h00;
      default:     Out_Data = In_Data;
    endcase
endmodule

module A_casez (input [7:0] In_Data, output reg [7:0] Out_Data);
  always @(In_Data)
    casez (In_Data)
      8'b???????1: Out_Data = In_Data ^ 8'hfe;
      8'b??????10: Out_Data = In_Data ^ 8'hfc;
      8'b?????100: Out_Data = In_Data ^ 8'hf8;
      8'b????1000: Out_Data = In_Data ^ 8'hf0;
      8'b???10000: Out_Data = In_Data ^ 8'he0;
      8'b??100000: Out_Data = In_Data ^ 8'hc0;
      8'b?1000000: Out_Data = In_Data ^ 8'h80;
      8'b10000000: Out_Data = In_Data ^ 8'h00;
      default:     Out_Data = In_Data;
    endcase
endmodule

module A_casex (input [7:0] In_Data, output reg [7:0] Out_Data);
  always @(In_Data)
    casex (In_Data)
      8'b???????1: Out_Data = In_Data ^ 8'hfe;
      8'b??????10: Out_Data = In_Data ^ 8'hfc;
      8'b?????100: Out_Data = In_Data ^ 8'hf8;
      8'b????1000: Out_Data = In_Data ^ 8'hf0;
      8'b???10000: Out_Data = In_Data ^ 8'he0;
      8'b??100000: Out_Data = In_Data ^ 8'hc0;
      8'b?1000000: Out_Data = In_Data ^ 8'h80;
      8'b10000000: Out_Data = In_Data ^ 8'h00;
      default:     Out_Data = In_Data;
    endcase
endmodule

// ---------------- (B) 以 x 撰寫 ----------------
module B_case (input [7:0] In_Data, output reg [7:0] Out_Data);
  always @(In_Data)
    case (In_Data)
      8'bxxxxxxx1: Out_Data = In_Data ^ 8'hfe;
      8'bxxxxxx10: Out_Data = In_Data ^ 8'hfc;
      8'bxxxxx100: Out_Data = In_Data ^ 8'hf8;
      8'bxxxx1000: Out_Data = In_Data ^ 8'hf0;
      8'bxxx10000: Out_Data = In_Data ^ 8'he0;
      8'bxx100000: Out_Data = In_Data ^ 8'hc0;
      8'bx1000000: Out_Data = In_Data ^ 8'h80;
      8'b10000000: Out_Data = In_Data ^ 8'h00;
      default:     Out_Data = In_Data;
    endcase
endmodule

module B_casez (input [7:0] In_Data, output reg [7:0] Out_Data);
  always @(In_Data)
    casez (In_Data)
      8'bxxxxxxx1: Out_Data = In_Data ^ 8'hfe;
      8'bxxxxxx10: Out_Data = In_Data ^ 8'hfc;
      8'bxxxxx100: Out_Data = In_Data ^ 8'hf8;
      8'bxxxx1000: Out_Data = In_Data ^ 8'hf0;
      8'bxxx10000: Out_Data = In_Data ^ 8'he0;
      8'bxx100000: Out_Data = In_Data ^ 8'hc0;
      8'bx1000000: Out_Data = In_Data ^ 8'h80;
      8'b10000000: Out_Data = In_Data ^ 8'h00;
      default:     Out_Data = In_Data;
    endcase
endmodule

module B_casex (input [7:0] In_Data, output reg [7:0] Out_Data);
  always @(In_Data)
    casex (In_Data)
      8'bxxxxxxx1: Out_Data = In_Data ^ 8'hfe;
      8'bxxxxxx10: Out_Data = In_Data ^ 8'hfc;
      8'bxxxxx100: Out_Data = In_Data ^ 8'hf8;
      8'bxxxx1000: Out_Data = In_Data ^ 8'hf0;
      8'bxxx10000: Out_Data = In_Data ^ 8'he0;
      8'bxx100000: Out_Data = In_Data ^ 8'hc0;
      8'bx1000000: Out_Data = In_Data ^ 8'h80;
      8'b10000000: Out_Data = In_Data ^ 8'h00;
      default:     Out_Data = In_Data;
    endcase
endmodule
