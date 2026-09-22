`timescale 1ns/1ps

// =====================================================================
// Rotate_Data：「載入」資料或「向左旋轉」資料
//   Reset = 1       → q 清除為 0
//   Left_Rotate = 1 → q 向左旋轉 1 位元（最高位繞回最低位）
//   否則            → 從輸入埠 data 載入資料到 q
// =====================================================================
module Rotate_Data (Clock, Reset, Left_Rotate, data, q);
    input        Clock, Reset, Left_Rotate;
    input  [7:0] data;
    output [7:0] q;
    reg    [7:0] q;

    always @(posedge Clock)
    begin
        if (Reset)
            q <= 8'b0;
        else if (Left_Rotate)
            q <= {q[6:0], q[7]};    // 連結運算子：q[6:0] 往左移，q[7] 補到最右邊
        else
            q <= data;
    end
endmodule
