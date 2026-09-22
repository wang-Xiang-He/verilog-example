`timescale 1ns/1ps

// =====================================================================
// R_Shift：quotient = dividend >> amount
//   右移 1 次 = 除以 2（無條件捨去），右移 n 次 = 除以 2^n
// =====================================================================
module R_Shift (dividend, amount, quotient);
    input  [7:0] dividend;
    input  [2:0] amount;       // 3 位元，可移 0~7 次
    output [7:0] quotient;
    wire   [7:0] quotient;

    assign quotient = dividend >> amount;   // 左邊空出來的位元補 0
endmodule
