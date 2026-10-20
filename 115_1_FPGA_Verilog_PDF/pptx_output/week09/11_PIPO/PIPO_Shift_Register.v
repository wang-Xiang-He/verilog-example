`timescale 1ns/1ps

// =====================================================================
// PIPO_Shift_Register：4 位元並進並出（Parallel In Parallel Out）暫存器（講義第 33~35 頁）
//   Clock 正緣且 Load = 1 時，Data_In 一次存進 Data_Out
// =====================================================================
module PIPO_Shift_Register (
    input            Clock,
    input            Clear,
    input            Load,
    input      [3:0] Data_In,
    output reg [3:0] Data_Out
);
    always @(posedge Clock) begin
        if (Clear)                      // 清除
            Data_Out <= 4'b0;           // 清為 0
        else if (Load)
            Data_Out <= Data_In;        // 從 Data_In 載入資料
    end
    // 講義第 34 頁：「有誤？請修正（加入 temp）」——這個寫法本身是標準的 PIPO 暫存器，模擬結果也正確
    //   講義第 35 頁的「建議修正」其實是想改變「什麼時候輸出」：
    //     (1) 負緣輸出  (2) Load = 0 時才輸出。下面兩個 new 版本是講義第 36~39 頁的嘗試
endmodule
