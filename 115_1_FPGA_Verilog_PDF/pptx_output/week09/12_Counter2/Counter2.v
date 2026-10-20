`timescale 1ns/1ps

// =====================================================================
// Counter2：具「重置」、「載入」及「致能輸出」控制的 8 位元正緣觸發上數計數器（講義第 40~42 頁）
//   priority：Reset（high）> Load > Enable（low），全部是同步控制
//   8 位元：0 ~ 255（2^8 = 256），255 再加 1 會回到 0
// =====================================================================
module Counter2 (
    input            Clock,
    input            Reset,
    input            Load,
    input            Enable,
    input      [7:0] Data_In,
    output reg [7:0] Out
);
    always @(posedge Clock) begin       // 同步控制
        if (Reset)                      // 重置
            Out <= 8'd0;                // 清除為 0
        else if (Load)                  // 載入
            Out <= Data_In;             // 從輸入埠 Data_In，載入計數值
        else if (Enable)                // 致能計數
            Out <= Out + 1'b1;          // 計數值 +1
    end
endmodule
