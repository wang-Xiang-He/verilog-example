`timescale 1ns/1ps

// =====================================================================
// Top2：依「名稱」（by name）連接埠，電路和 Top1 完全相同
//   .子模組埠名(外部訊號)，埠的順序就無所謂了
//   同一個實例裡「依順序」和「依名稱」不能混用，但不同實例可以各用一種
// =====================================================================
module Top2 (Clock, Reset, Sel, Left_Rotate, a, b, out);
    input        Clock, Reset, Sel, Left_Rotate;
    input  [7:0] a, b;
    output [7:0] out;
    wire   [7:0] Mux_Out, Reg_Out;

    // 依名稱：故意打亂順序也沒關係
    Mux         Mux_1         (.out(Mux_Out), .Sel(Sel), .b(b), .a(a));
    Register8   Register8_1   (.Clock(Clock), .Reset(Reset), .data(Mux_Out), .q(Reg_Out));
    // 依順序
    Rotate_Data Rotate_Data_1 (Clock, Reset, Left_Rotate, Reg_Out, out);
endmodule
