// ============================================================
//  W9-2：單埠 RAM（Single-Port）
//  重點：同一個位址埠，同一時間只能讀或只能寫
// ============================================================
`timescale 1ns / 1ps

module ram_sp #(
    parameter AW = 4,               // 位址寬度 → 深度 2^4 = 16
    parameter DW = 8                // 資料寬度
)(
    input  wire          clk,
    input  wire          we,        // write enable
    input  wire [AW-1:0] addr,
    input  wire [DW-1:0] din,
    output reg  [DW-1:0] dout
);

    // ★ 這一行就是記憶體陣列的宣告方式
    //   [DW-1:0] 是每格多寬，[0:2**AW-1] 是有幾格
    reg [DW-1:0] mem [0:(2**AW)-1];

    integer i;
    initial begin
        for (i = 0; i < 2**AW; i = i + 1)
            mem[i] = {DW{1'b0}};
    end

    always @(posedge clk) begin
        if (we)
            mem[addr] <= din;       // 寫入

        dout <= mem[addr];          // 讀出（永遠讀，同步）
                                    // ★ 注意：同一拍又寫又讀時，
                                    //   dout 拿到的是「舊值」（read-first）
    end

endmodule
