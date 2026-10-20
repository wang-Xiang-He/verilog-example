`timescale 1ns/1ps

// =====================================================================
// SISO_Shift_Register_For：4 位元串進串出，左移，移位暫存器（使用 for 敘述）（範例 2，講義第 23、24 頁）
//   ※ 講義兩個範例的模組名稱都是 SISO_Shift_Register，放在一起編譯會互相覆蓋，這個改名為 _For
// =====================================================================
module SISO_Shift_Register_For (
    input      Clock,
    input      Clear,
    input      SI,
    output reg SO
);
    reg [3:0] Reg4;

    always @(posedge Clock) begin : for_Local   // 定義一個區域名稱 for_Local
        integer i;                              // 定義一個區域性變數
        if (Clear)                              // 清除
            Reg4 <= 4'b0;                       // 清為 0
        else begin
            SO <= Reg4[3];
            for (i = 3; i >= 1; i = i - 1)      // loop：Reg4[3] = Reg4[2]、Reg4[2] = Reg4[1]、Reg4[1] = Reg4[0]
                Reg4[i] <= Reg4[i-1];
            Reg4[0] <= SI;                      // 移入新的資料（SI）至 Reg4[0]
        end
    end
endmodule
