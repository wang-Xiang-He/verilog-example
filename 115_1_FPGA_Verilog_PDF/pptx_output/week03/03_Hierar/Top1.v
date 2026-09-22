`timescale 1ns/1ps

// =====================================================================
// Top1：依「順序」（by order / in order）連接埠
//   資料路徑：a/b → Mux → Mux_Out → Register8 → Reg_Out → Rotate_Data → out
//   ※ 需要 Mux.v、Register8.v、Rotate_Data.v 一起編譯
// =====================================================================
module Top1 (Clock, Reset, Sel, Left_Rotate, a, b, out);
    input        Clock, Reset, Sel, Left_Rotate;
    input  [7:0] a, b;
    output [7:0] out;
    wire   [7:0] Mux_Out, Reg_Out;  // 模組之間的內部連線

    // 依順序：括號內的訊號必須和子模組宣告的埠順序一一對應
    Mux         Mux_1         (Sel, a, b, Mux_Out);
    Register8   Register8_1   (Clock, Reset, Mux_Out, Reg_Out);
    Rotate_Data Rotate_Data_1 (Clock, Reset, Left_Rotate, Reg_Out, out);
endmodule
