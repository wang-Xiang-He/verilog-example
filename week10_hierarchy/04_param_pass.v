// ============================================================
//  W10-4：參數往下傳                   ← 課本 11.3（易於調整的設計）
//  重點：★ 只改頂層一個數字，整條階層的每一層都跟著變
//        這是「可調整設計 Scalable Design」的核心
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  最底層：一位元全加器（完全不知道自己會被用在幾位元的加法器裡）
// ------------------------------------------------------------
module fa_cell (
    input  wire a, b, cin,
    output wire sum, cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule


// ------------------------------------------------------------
//  中間層：N 位元漣波進位加法器
//  ★ 用 generate 把 N 顆 fa_cell 串起來（第 4 週 03_generate 學的）
// ------------------------------------------------------------
module adder_n #(
    parameter N = 8
) (
    input  wire [N-1:0] a, b,
    input  wire         cin,
    output wire [N-1:0] sum,
    output wire         cout
);
    wire [N:0] carry;
    assign carry[0] = cin;
    assign cout     = carry[N];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : bit_slice
            fa_cell u_fa (
                .a(a[i]), .b(b[i]), .cin(carry[i]),
                .sum(sum[i]), .cout(carry[i+1])
            );
        end
    endgenerate
endmodule


// ------------------------------------------------------------
//  中間層：N 位元暫存器
// ------------------------------------------------------------
module reg_n #(
    parameter N = 8
) (
    input  wire         clk, rst_n, en,
    input  wire [N-1:0] d,
    output reg  [N-1:0] q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)   q <= {N{1'b0}};
        else if (en)  q <= d;
    end
endmodule


// ------------------------------------------------------------
//  頂層：一個累加器
//
//  ★★ 全檔【只有這裡一個 WIDTH】，改它就好，下面全部自動跟著變。
//     從頂層 → adder_n → fa_cell，參數一路傳三層。
// ------------------------------------------------------------
module param_accum #(
    parameter WIDTH = 8
) (
    input  wire             clk, rst_n, en,
    input  wire [WIDTH-1:0] din,
    output wire [WIDTH-1:0] acc,
    output wire             cout,

    //  ---- 由 WIDTH 推算出來的東西 ----
    output wire [7:0]       reported_width,
    output wire [7:0]       reported_addr_bits,
    output wire [WIDTH-1:0] reported_max
);

    //  ★ localparam 是「算出來的參數」，不能從外面覆寫。
    //    凡是【由別的參數推導出來】的值，一律用 localparam，
    //    不要用 parameter —— 否則別人可以從外面把它改成矛盾的值。
    localparam ADDR_BITS = clog2(WIDTH);
    localparam [WIDTH-1:0] MAXVAL = {WIDTH{1'b1}};

    function integer clog2;
        input integer v;
        integer i;
        begin
            clog2 = 0;
            for (i = v - 1; i > 0; i = i >> 1) clog2 = clog2 + 1;
        end
    endfunction

    assign reported_width     = WIDTH[7:0];
    assign reported_addr_bits = ADDR_BITS[7:0];
    assign reported_max       = MAXVAL;

    wire [WIDTH-1:0] sum_w;

    //  ★ 參數往下傳：把自己的 WIDTH 傳給子模組的 N
    adder_n #(.N(WIDTH)) u_add (
        .a(acc), .b(din), .cin(1'b0),
        .sum(sum_w), .cout(cout)
    );

    reg_n #(.N(WIDTH)) u_reg (
        .clk(clk), .rst_n(rst_n), .en(en),
        .d(sum_w), .q(acc)
    );

endmodule

//  iverilog -o sim.out 04_param_pass.v 04_param_pass_tb.v
//  vvp sim.out
//  gtkwave 04_param_pass.gtkw
