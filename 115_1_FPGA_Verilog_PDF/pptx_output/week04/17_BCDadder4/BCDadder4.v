`timescale 1ns/1ps

// =====================================================================
// BCDadder4：1 位數（4 位元）BCD 加法器（範例練習 5-005，講義第 50~53 頁）
//   第 1 個 adder4（BINADD）：先做一般二進位加法 → {C4, S_tmp}
//   F = C4 + S3·S2 + S3·S1 = C4 + S3(S2 + S1)   （結果 > 9 時 F = 1）
//   第 2 個 adder4（MODADD）：F = 1 時加 6（0110）修正，F = 0 時加 0
//   Cout = F（十進位的進位）
// =====================================================================
module BCDadder4 (
    output [3:0] S,               // 埠順序和講義相同：(S, Cout, Cin, A, B)
    output       Cout,
    input        Cin,
    input  [3:0] A,
    input  [3:0] B
);
    wire [3:0] S_tmp;
    wire       C4;
    reg  [3:0] B_mod;
    reg        F;

    adder4 BINADD (.A(A),     .B(B),     .Cin(Cin),  .S(S_tmp), .Cout(C4));
    adder4 MODADD (.A(S_tmp), .B(B_mod), .Cin(1'b0), .S(S),     .Cout());  // 第 2 級的進位不用

    always @(*) begin             // 講義：always @(Cin or A or B or C4 or S_tmp)
        F     = C4 | (S_tmp[3] & (S_tmp[2] | S_tmp[1]));
        B_mod = {1'b0, F, F, 1'b0};   // F = 1 → 0110（6）；F = 0 → 0000
    end

    assign Cout = F;
endmodule
