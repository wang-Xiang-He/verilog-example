`timescale 1ns/1ps

// =====================================================================
// Mux2to1_3：2 對 1 多工器，第 3 種寫法：if ... else，且考慮 Select 為不確定值（講義第 33、34 頁）
//   這種寫法多考慮了：如果 Select 不等於 1 也不等於 0 時，則令 Out = 1'bx（不確定值，Unknown）
// =====================================================================
module Mux2to1_3 (
    input  a,
    input  b,
    input  Select,
    output reg Out
);
    always @(*) begin
        if (Select == 1'b1) begin
            Out = a;
        end
        else if (Select == 1'b0) begin
            Out = b;
        end
        else begin
            Out = 1'bx;         // 不確定值，Unknown
        end
    end
endmodule
