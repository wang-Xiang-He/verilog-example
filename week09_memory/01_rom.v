// ============================================================
//  W9-1：ROM —— 唯讀記憶體
//  重點：兩種寫法（case 表 / 從檔案載入），以及同步 vs 非同步讀取
// ============================================================
`timescale 1ns / 1ps

module rom (
    input  wire       clk,
    input  wire [3:0] addr,
    output wire [7:0] data_async,   // 非同步讀：位址一變資料立刻出來
    output reg  [7:0] data_sync     // 同步讀：等一個時脈才出來
);

    // ---------- 寫法 1：用 case 當查表 ----------
    //  綜合工具會把它變成純組合邏輯（LUT），
    //  適合小容量、內容固定的表
    function [7:0] rom_table;
        input [3:0] a;
        begin
            case (a)
                4'd0:  rom_table = 8'h00;
                4'd1:  rom_table = 8'h01;
                4'd2:  rom_table = 8'h04;
                4'd3:  rom_table = 8'h09;
                4'd4:  rom_table = 8'h10;
                4'd5:  rom_table = 8'h19;
                4'd6:  rom_table = 8'h24;
                4'd7:  rom_table = 8'h31;
                4'd8:  rom_table = 8'h40;
                4'd9:  rom_table = 8'h51;
                4'd10: rom_table = 8'h64;
                4'd11: rom_table = 8'h79;
                4'd12: rom_table = 8'h90;
                4'd13: rom_table = 8'hA9;
                4'd14: rom_table = 8'hC4;
                4'd15: rom_table = 8'hE1;
                default: rom_table = 8'h00;
            endcase
        end
    endfunction

    // 非同步讀取
    assign data_async = rom_table(addr);

    // 同步讀取（把輸出接一個正反器）
    //  ★ FPGA 的 Block RAM 只支援同步讀取，
    //    寫成這樣綜合工具才會用 BRAM，不會浪費 LUT
    always @(posedge clk) begin
        data_sync <= rom_table(addr);
    end

endmodule
