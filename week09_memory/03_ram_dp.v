// ============================================================
//  W9-3：雙埠 RAM（Dual-Port）
//  重點：兩組獨立的位址埠 → 可以「同時」讀一個地方、寫另一個地方
// ============================================================
`timescale 1ns / 1ps

module ram_dp #(
    parameter AW = 4,
    parameter DW = 8
)(
    input  wire          clk,
    // A 埠：只寫
    input  wire          a_we,
    input  wire [AW-1:0] a_addr,
    input  wire [DW-1:0] a_din,
    // B 埠：只讀
    input  wire [AW-1:0] b_addr,
    output reg  [DW-1:0] b_dout
);

    reg [DW-1:0] mem [0:(2**AW)-1];

    integer i;
    initial for (i = 0; i < 2**AW; i = i + 1) mem[i] = {DW{1'b0}};

    // 兩個埠各自獨立運作，互不干擾
    always @(posedge clk) begin
        if (a_we) mem[a_addr] <= a_din;     // A 埠寫
    end

    always @(posedge clk) begin
        b_dout <= mem[b_addr];              // B 埠讀
    end

    //  ★ 注意「同位址衝突」：如果同一拍 a_addr == b_addr 而且 a_we=1，
    //    b_dout 拿到的是新值還是舊值取決於實作與硬體。
    //    設計時不要依賴這個行為。

endmodule
