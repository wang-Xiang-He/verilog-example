// ============================================================
//  W5-2：待測物 —— 一個 4 位元 ALU
//  （設計本身不是重點，重點是它的測試平台怎麼寫）
// ============================================================
`timescale 1ns / 1ps

module alu4 (
    input  wire [3:0] a, b,
    input  wire [2:0] op,
    output reg  [4:0] y,
    output wire       zero
);
    always @(*) begin
        case (op)
            3'd0: y = a + b;
            3'd1: y = a - b;
            3'd2: y = a & b;
            3'd3: y = a | b;
            3'd4: y = a ^ b;
            3'd5: y = ~a;
            3'd6: y = a << 1;
            3'd7: y = a >> 1;
            default: y = 5'bx;
        endcase
    end

    assign zero = (y == 5'd0);
endmodule
