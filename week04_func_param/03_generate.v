// ============================================================
//  W4-3：generate —— 用迴圈「複製」硬體
//  重點：generate 的 for 不是執行迴圈，是「複製零件」的指示
// ============================================================
`timescale 1ns / 1ps

module full_adder1 (
    input  wire a, b, cin,
    output wire sum, cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule


// ---------- N 位元漣波進位加法器 ----------
//  不用 generate 的話，8 位元就要手寫 8 次實例化。
//  用 generate，一段就搞定，而且改 N 就換寬度。
module ripple_adder #(
    parameter N = 8
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire         cin,
    output wire [N-1:0] sum,
    output wire         cout
);

    wire [N:0] carry;            // N+1 條進位線
    assign carry[0] = cin;
    assign cout     = carry[N];

    genvar i;                    // ★ generate 專用的迴圈變數
    generate
        for (i = 0; i < N; i = i + 1) begin : adder_stage
            full_adder1 fa (
                .a    (a[i]),
                .b    (b[i]),
                .cin  (carry[i]),
                .sum  (sum[i]),
                .cout (carry[i+1])   // 這一級的進位接到下一級
            );
        end
    endgenerate

endmodule
