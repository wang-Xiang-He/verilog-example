// FullAdd.v : 1 位元全加器（期中考 第 1 題）
module FullAdd (S, Cout, A, B, Cin);
  output S, Cout;
  input  A, B, Cin;

  assign S    = A ^ B ^ Cin;
  assign Cout = (A & B) | (A & Cin) | (B & Cin);
endmodule
