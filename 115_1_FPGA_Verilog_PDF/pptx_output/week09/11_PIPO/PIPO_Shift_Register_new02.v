`timescale 1ns/1ps

// =====================================================================
// PIPO_Shift_Register_new02：temp 改成 wire，用 assign temp = Data_In（講義第 38、39 頁，4_16_PIPO_new02）
//   wire temp 只是一條線，沒有記憶 → Data_Out <= temp 等於 Data_Out <= Data_In，結果和原版完全一樣
// =====================================================================
module PIPO_Shift_Register_new02 (
    input            Clock,
    input            Clear,
    input            Load,
    input      [3:0] Data_In,
    output reg [3:0] Data_Out
);
    wire [3:0] temp;
    assign temp = Data_In;              // (1)

    always @(posedge Clock) begin       // (2)
        if (Clear)
            Data_Out <= 4'b0;
        else if (Load)
            Data_Out <= temp;           // 從 Data_In 載入資料
    end
endmodule
