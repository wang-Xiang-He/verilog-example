// ============================================================
//  W5-3：`timescale 到底在做什麼
//  重點：它決定 #1 有多久，也決定波形圖橫軸的單位
// ============================================================
`timescale 1ns / 1ps
//         ^^^   ^^^
//         單位   精度
//   單位：#1 代表多久        → 這裡是 1ns
//   精度：模擬器能分辨多細    → 這裡是 1ps（也就是 #0.001 有意義）

module clk_gen (
    input  wire rst,
    output reg  clk_10ns,     // 週期 10ns  = 100 MHz
    output reg  clk_40ns      // 週期 40ns  = 25 MHz
);
    initial begin
        clk_10ns = 0;
        clk_40ns = 0;
    end

    always #5  clk_10ns = ~clk_10ns;    // 半週期 5ns
    always #20 clk_40ns = ~clk_40ns;    // 半週期 20ns
endmodule
