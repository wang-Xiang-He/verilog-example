`timescale 1ns/1ps

// =====================================================================
// Encoder3：8 對 3 優先權編碼器，用 always + if ... else if ...（講義第 21、22 頁，Good Design）
//   if ... else if 的「先寫的先判斷」就是優先權：h 最先判斷，所以 h 最高
// =====================================================================
module Encoder3 (
    input            a, b, c, d, e, f, g, h,
    output reg [3:0] Out_Vect,
    output           None_ON,
    output           Out2,
    output           Out1,
    output           Out0
);
    // 連結運算子放在等號左邊：Out_Vect[3] → None_ON、[2] → Out2、[1] → Out1、[0] → Out0
    assign {None_ON, Out2, Out1, Out0} = Out_Vect;

    always @(*) begin           // 講義：always @(a or b or c or d or e or f or g or h)
             if (h) Out_Vect = 4'b0111;     // High
        else if (g) Out_Vect = 4'b0110;
        else if (f) Out_Vect = 4'b0101;
        else if (e) Out_Vect = 4'b0100;     // Priority
        else if (d) Out_Vect = 4'b0011;
        else if (c) Out_Vect = 4'b0010;
        else if (b) Out_Vect = 4'b0001;
        else if (a) Out_Vect = 4'b0000;     // Low
        else        Out_Vect = 4'b1000;     // 全部是 0
    end
endmodule
