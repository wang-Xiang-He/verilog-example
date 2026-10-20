`timescale 1ns/1ps

// =====================================================================
// Counter3：具「載入」及「進位」訊號的 8 位元（0~255）正緣觸發上數計數器（講義第 43~45 頁）
//   用兩個 always 區塊：
//     第一個 Block（時脈）：Clock 正緣時，把 Pre_Out 的值傳至 Out
//     第二個 Block（組合）：計算下一個計數器的狀態 Pre_Out 及 Carry_Out
//   Carry_In = 1 才計數（相當於致能）；Out = 255 且 Carry_In = 1 時 Carry_Out = 1
// =====================================================================
module Counter3 (
    input            Clock,
    input            Load,
    input            Carry_In,
    input      [7:0] Data_In,
    output reg [7:0] Out,
    output reg       Carry_Out
);
    reg [7:0] Pre_Out;                  // 下一個狀態

    // 產生一個 8 位元的暫存器
    always @(posedge Clock)             // 當 Clock 正緣觸發時
        Out <= Pre_Out;                 // 更新 Out 值

    // 計算下一個計數器的狀態及 Carry_Out 的值
    //   基於「效能」上的考量，我們不希望 Load 訊號影響 Carry_Out：Load 只影響 Pre_Out
    always @(*) begin                   // 講義：always @(Load or Data_In or Carry_In or Out)
        {Carry_Out, Pre_Out} = Out + Carry_In;
        if (Load)                       // 載入
            Pre_Out = Data_In;          // 從輸入埠 Data_In，載入計數值到 Pre_Out
    end
    // 組合邏輯的 always 用阻隔式 =：第 2 行要「覆蓋」第 1 行算出的 Pre_Out
endmodule
