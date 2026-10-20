`timescale 1ns/1ps

// =====================================================================
// Counter6：具有「重置」、「載入」、「致能」及「上 / 下數」訊號控制的 8 位元（0~255）正緣觸發上數 / 下數計數器
//   （講義第 51、52 頁）
//   Priority：Reset > Load > Enable > Up_Down
//   Up_Down = 1 → 上數（+1）；Up_Down = 0 → 下數（-1）
// =====================================================================
module Counter6 (
    input            Clock,
    input            Reset,
    input            Load,
    input            Enable,
    input            Up_Down,
    input      [7:0] Data_In,
    output reg [7:0] Out
);
    always @(posedge Clock) begin
        if (Reset)
            Out <= 8'd0;                // 清除為 0
        else if (Load)                  // 載入
            Out <= Data_In;             // 從輸入埠 Data_In，載入計數值
        else if (Enable) begin          // 致能計數
            if (Up_Down)                // 上數 / 下數
                Out <= Out + 1'b1;      // 計數值 +1，上數
            else
                Out <= Out - 1'b1;      // 計數值 -1，下數
        end
    end
endmodule
