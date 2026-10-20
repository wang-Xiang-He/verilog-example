`timescale 1ns/1ps

// =====================================================================
// PIPO_Shift_Register_new01：加入 reg temp（講義第 36、37 頁，4_16_PIPO_new01）
//   每個正緣：Data_Out 拿 temp 的舊值，temp 再存 Data_In → Data_Out 晚一個時脈
//   講義：「第一筆資料不見了，請修正程式。」
// =====================================================================
module PIPO_Shift_Register_new01 (
    input            Clock,
    input            Clear,
    input            Load,
    input      [3:0] Data_In,
    output reg [3:0] Data_Out
);
    reg [3:0] temp;

    always @(posedge Clock) begin
        if (Clear)
            Data_Out <= 4'b0;
        else if (Load) begin
            Data_Out <= temp;           // 從 temp 輸出上一次存的資料
            temp     <= Data_In;
        end
    end
endmodule
