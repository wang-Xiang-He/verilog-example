`timescale 1ns/1ps

// =====================================================================
// Add_or_Subtract：op == ADD 則 s = a + b，否則 s = a - b
//   parameter：模組內的常數，改一個地方就能改整個電路的位元寬度
// =====================================================================
module Add_or_Subtract (a, b, op, s);
    parameter SIZE = 8;
    parameter ADD  = 1'b1;
    input             op;
    input  [SIZE-1:0] a, b;
    output [SIZE-1:0] s;

    assign s = (op == ADD) ? a + b : a - b;
    // 結果只取 SIZE 位元，超出的進位 / 借位會被丟掉（例如 255 + 1 = 0）
endmodule
