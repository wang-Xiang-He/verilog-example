// case_compare_tb.v : 比較 (A)(B) 在 case / casez / casex 下的結果
`timescale 1ns/1ps
module case_compare_tb;
  reg  [7:0] In_Data;
  wire [7:0] Aca, Acz, Acx, Bca, Bcz, Bcx;
  wire [7:0] golden = -In_Data;              // 正確答案：2 的補數
  integer k, eAca, eAcz, eAcx, eBca, eBcz, eBcx;

  A_case  u1 (In_Data, Aca);
  A_casez u2 (In_Data, Acz);
  A_casex u3 (In_Data, Acx);
  B_case  u4 (In_Data, Bca);
  B_casez u5 (In_Data, Bcz);
  B_casex u6 (In_Data, Bcx);

  initial begin
    eAca = 0; eAcz = 0; eAcx = 0; eBca = 0; eBcz = 0; eBcx = 0;
    $display(" In_Data  | -In      | A:case   A:casez  A:casex  | B:case   B:casez  B:casex");
    for (k = 0; k < 256; k = k + 1) begin
      In_Data = k;
      #1;
      if (k == 1 || k == 6 || k == 12 || k == 80 || k == 128 || k == 255)
        $display(" %b | %b | %b %b %b | %b %b %b",
                 In_Data, golden, Aca, Acz, Acx, Bca, Bcz, Bcx);
      if (Aca !== golden) eAca = eAca + 1;
      if (Acz !== golden) eAcz = eAcz + 1;
      if (Acx !== golden) eAcx = eAcx + 1;
      if (Bca !== golden) eBca = eBca + 1;
      if (Bcz !== golden) eBcz = eBcz + 1;
      if (Bcx !== golden) eBcx = eBcx + 1;
    end
    $display("errors out of 256 inputs:");
    $display("  (A) ? pattern : case=%0d  casez=%0d  casex=%0d", eAca, eAcz, eAcx);
    $display("  (B) x pattern : case=%0d  casez=%0d  casex=%0d", eBca, eBcz, eBcx);
    $finish;
  end
endmodule
// 【預期輸出】(A) case 錯、casez 對、casex 對；(B) case 錯、casez 錯、casex 對
// 【ModelSim 執行指令】 do run_case.do
