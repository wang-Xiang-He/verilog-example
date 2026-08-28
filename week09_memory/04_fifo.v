// ============================================================
//  W9-4：FIFO —— 先進先出佇列
//  重點：★ 空 / 滿怎麼判斷 ★（這是 FIFO 唯一的難點）
// ============================================================
`timescale 1ns / 1ps

module fifo #(
    parameter AW = 3,               // 深度 2^3 = 8
    parameter DW = 8
)(
    input  wire          clk,
    input  wire          rst,
    // 寫入端
    input  wire          wr_en,
    input  wire [DW-1:0] wr_data,
    output wire          full,
    // 讀出端
    input  wire          rd_en,
    output reg  [DW-1:0] rd_data,
    output wire          empty,
    // 狀態
    output wire [AW:0]   count       // 目前存了幾筆（多一位元才裝得下「全滿」）
);

    reg [DW-1:0] mem [0:(2**AW)-1];

    //  ★ 指標多用一個位元（wrap bit）—— 這是判斷空滿的關鍵技巧
    //     位址部分相同 + wrap bit 相同 → 空
    //     位址部分相同 + wrap bit 不同 → 滿
    reg [AW:0] wr_ptr, rd_ptr;

    wire do_wr = wr_en && !full;
    wire do_rd = rd_en && !empty;

    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr[AW-1:0] == rd_ptr[AW-1:0]) &&
                   (wr_ptr[AW]     != rd_ptr[AW]);
    assign count = wr_ptr - rd_ptr;

    always @(posedge clk) begin
        if (rst) begin
            wr_ptr  <= 0;
            rd_ptr  <= 0;
            rd_data <= {DW{1'b0}};
        end else begin
            if (do_wr) begin
                mem[wr_ptr[AW-1:0]] <= wr_data;
                wr_ptr <= wr_ptr + 1'b1;
            end
            if (do_rd) begin
                rd_data <= mem[rd_ptr[AW-1:0]];
                rd_ptr  <= rd_ptr + 1'b1;
            end
        end
    end

endmodule
