`timescale 1ns/1ps

// =====================================================================
// Mux2to1_4：2 對 1 多工器，第 4 種寫法：case，且考慮 Select 為不確定值（講義第 35、36 頁）
// =====================================================================
module Mux2to1_4 (
    input  a,
    input  b,
    input  Select,
    output reg Out
);
    always @(*) begin
        case (Select)
            1'b1:    Out = a;   // Select = 1 則 Out = a
            1'b0:    Out = b;   // Select = 0 則 Out = b
            default: Out = 1'bx;// 不確定值，Unknown
        endcase
    end
endmodule
