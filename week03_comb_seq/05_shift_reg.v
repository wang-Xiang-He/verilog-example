// ============================================================
//  W3-5：移位暫存器（可載入、可左右移）
//  重點：把前面學的 case + 非阻塞 + 位元串接組合起來用
// ============================================================
`timescale 1ns / 1ps

module shift_reg (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] mode,      // 00=保持 01=左移 10=右移 11=載入
    input  wire       sin,       // 移進來的那一位
    input  wire [7:0] load_data,
    output reg  [7:0] q
);

    always @(posedge clk) begin
        if (rst)
            q <= 8'b0;
        else case (mode)
            2'b00: q <= q;                   // 保持
            2'b01: q <= {q[6:0], sin};       // 左移：低位補 sin
            2'b10: q <= {sin, q[7:1]};       // 右移：高位補 sin
            2'b11: q <= load_data;           // 平行載入
        endcase
    end

endmodule
