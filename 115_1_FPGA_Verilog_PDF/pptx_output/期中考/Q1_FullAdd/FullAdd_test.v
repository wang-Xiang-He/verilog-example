// FullAdd_test.v : FullAdd 的測試平台（期中考 第 1 題）
`timescale 1ns/1ps
module FullAdd_test;
  reg  A, B, Cin;
  wire S, Cout;
  integer k, err;

  FullAdd UUT (.S(S), .Cout(Cout), .A(A), .B(B), .Cin(Cin));

  initial begin
    err = 0;
    $display(" time  A B Cin | Cout S");
    for (k = 0; k < 8; k = k + 1) begin
      {A, B, Cin} = k;
      #10;
      $display("%4d  %b %b  %b  |  %b   %b", $time, A, B, Cin, Cout, S);
      if ({Cout, S} !== A + B + Cin) err = err + 1;
    end
    if (err == 0) $display("PASS: all 8 cases correct");
    else          $display("FAIL: %0d errors", err);
    $finish;
  end
endmodule

// 【預期輸出】{Cout,S} = A+B+Cin，最後印出 PASS: all 8 cases correct
// 【ModelSim 執行指令】 do run.do
