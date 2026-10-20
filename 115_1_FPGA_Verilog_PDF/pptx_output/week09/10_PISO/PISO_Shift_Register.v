`timescale 1ns/1ps

// =====================================================================
// PISO_Shift_Register：4 位元並進串出（Parallel In Serial Out），左移，移位暫存器（講義第 29~32 頁）
//   Load = 1：Clock 正緣時把 Data_In[3:0] 一次載入 Reg4
//   Load = 0：Clock 正緣時 SO 送出 Reg4[3]，Reg4 左移一格，Reg4[0] 填入 0
// =====================================================================
module PISO_Shift_Register (
    input            Clock,
    input            Clear,
    input            Load,
    input      [3:0] Data_In,
    output reg       SO
);
    reg [3:0] Reg4;

    always @(posedge Clock) begin : for_Local   // 定義一個區域名稱 for_Local
        integer i;                              // 定義一個區域性變數
        if (Clear)                              // 清除
            Reg4 <= 4'b0;                       // 清除為 0
        else begin
            if (Load)
                Reg4 <= Data_In;                // 從 Data_In[3:0] 載入資料
            else begin
                SO <= Reg4[3];
                for (i = 3; i >= 1; i = i - 1)  // Reg4[3] = Reg4[2]、Reg4[2] = Reg4[1]、Reg4[1] = Reg4[0]
                    Reg4[i] <= Reg4[i-1];
                Reg4[0] <= 1'b0;                // Reg4[0] 填入 0
            end
        end
    end
endmodule
