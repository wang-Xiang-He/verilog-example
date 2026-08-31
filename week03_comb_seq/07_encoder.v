// ============================================================
//  W3-7：編碼器與優先編碼器          ← 課本 8.1.2
//  重點：★ 編碼器是解碼器的反向；沒處理好「同時多位是 1」就會出事
// ============================================================
`timescale 1ns / 1ps

module encoder (
    input  wire [7:0] din,

    output reg  [2:0] code_plain,   // 普通編碼器：假設只有一位是 1
    output reg  [2:0] code_pri,     // 優先編碼器：用 if-else 串出優先權
    output reg  [2:0] code_casez,   // 優先編碼器：用 casez 寫（課本 5.8）
    output reg        valid         // din 全 0 時 = 0
);

    // --------------------------------------------------------
    //  普通編碼器（8.1.2）
    //  只列出「剛好一位是 1」的 8 種情況，其他一律 default
    //  ★ 問題：同時有兩位是 1 就只能吐 default —— 這就是要有優先編碼器的原因
    // --------------------------------------------------------
    always @(*) begin
        case (din)
            8'b0000_0001: code_plain = 3'd0;
            8'b0000_0010: code_plain = 3'd1;
            8'b0000_0100: code_plain = 3'd2;
            8'b0000_1000: code_plain = 3'd3;
            8'b0001_0000: code_plain = 3'd4;
            8'b0010_0000: code_plain = 3'd5;
            8'b0100_0000: code_plain = 3'd6;
            8'b1000_0000: code_plain = 3'd7;
            default:      code_plain = 3'bxxx;   // ★ 多位同時是 1 → 無法判斷
        endcase
    end

    // --------------------------------------------------------
    //  優先編碼器：由高位往低位找，找到第一個 1 就回報
    //  if-else 天生就有優先權（寫在前面的贏），正好拿來做這件事
    // --------------------------------------------------------
    always @(*) begin
        valid = 1'b1;
        if      (din[7]) code_pri = 3'd7;
        else if (din[6]) code_pri = 3'd6;
        else if (din[5]) code_pri = 3'd5;
        else if (din[4]) code_pri = 3'd4;
        else if (din[3]) code_pri = 3'd3;
        else if (din[2]) code_pri = 3'd2;
        else if (din[1]) code_pri = 3'd1;
        else if (din[0]) code_pri = 3'd0;
        else begin
            code_pri = 3'd0;
            valid    = 1'b0;      // ★ 全 0 要用另一條線說「這次沒有結果」
        end
    end

    // --------------------------------------------------------
    //  同一件事用 casez 寫（課本 5.8）
    //  casez 裡的 ? 代表「這一位我不管」，由上往下比，第一個中的贏
    //  → 寫起來比 if-else 短，優先權一樣清楚
    // --------------------------------------------------------
    always @(*) begin
        casez (din)
            8'b1???_????: code_casez = 3'd7;
            8'b01??_????: code_casez = 3'd6;
            8'b001?_????: code_casez = 3'd5;
            8'b0001_????: code_casez = 3'd4;
            8'b0000_1???: code_casez = 3'd3;
            8'b0000_01??: code_casez = 3'd2;
            8'b0000_001?: code_casez = 3'd1;
            8'b0000_0001: code_casez = 3'd0;
            default:      code_casez = 3'd0;
        endcase
    end

endmodule

//  iverilog -o sim.out 07_encoder.v 07_encoder_tb.v
//  vvp sim.out
//  gtkwave 07_encoder.gtkw
