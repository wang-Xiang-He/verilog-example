`timescale 1ns/1ps

// =====================================================================
// Concate：連結運算子（Concatenation）{ , }
//   swap = 1：word = {byte2, byte1}（byte2 放高 4 位元）
//   swap = 0：word = {byte1, byte2}（byte1 放高 4 位元）
// =====================================================================
module Concate (swap, byte1, byte2, word);
    input        swap;
    input  [3:0] byte1;
    input  [3:0] byte2;
    output [7:0] word;
    reg    [7:0] word;

    always @(swap or byte1 or byte2)
    begin
        if (swap)
            word = {byte2, byte1};   // 等於 byte2 << 4 + byte1
        else
            word = {byte1, byte2};   // 等於 byte1 << 4 + byte2
    end
endmodule
