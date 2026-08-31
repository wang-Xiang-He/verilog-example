// ============================================================
//  W15-2：PWM 呼吸燈
//  重點：★ 數位電路怎麼做出「亮度」這種類比的東西？
//        答案：靠快速開關 + 人眼的視覺暫留。
//
//        PWM = 脈寬調變 (Pulse Width Modulation)
//        在一個固定週期裡，「亮」佔多少比例，看起來就多亮。
//
//        工作週期 10%  →  ▁▁▁▁▁▁▁▁▁█   很暗
//        工作週期 50%  →  ▁▁▁▁▁█████   一半
//        工作週期 90%  →  ▁█████████   很亮
// ============================================================
`timescale 1ns / 1ps

module pwm #(
    parameter CLK_HZ   = 12_000_000,
    parameter PWM_BITS = 8,             // 解析度：8 位元 = 256 階亮度
    parameter BREATH_HZ = 1             // 一秒呼吸一次
) (
    input  wire clk,
    output wire pwm_out,       // 呼吸燈
    output wire pwm_out2,      // 固定 25% 亮度（對照組）
    output wire tick
);

    // --------------------------------------------------------
    //  一、PWM 產生器本體
    //  一個一直繞圈的計數器 + 一個比較器，就這樣而已
    //
    //  ★ PWM 頻率 = CLK_HZ / 2^PWM_BITS
    //    = 12MHz / 256 = 46875 Hz
    //    遠高於人眼能分辨的 60Hz，所以看起來是穩定的亮度
    // --------------------------------------------------------
    reg [PWM_BITS-1:0] pwm_cnt = 0;
    always @(posedge clk) pwm_cnt <= pwm_cnt + 1'b1;

    reg [PWM_BITS-1:0] duty = 0;

    //  ★ 比較器：計數器還沒數到 duty 就輸出 1，之後輸出 0
    assign pwm_out  = (pwm_cnt < duty);
    assign pwm_out2 = (pwm_cnt < (1 << (PWM_BITS-2)));   // 固定 25%

    // --------------------------------------------------------
    //  二、讓 duty 慢慢變大變小 —— 這就是「呼吸」
    //
    //  ★ 分頻：duty 每秒要走完 0→255→0，共 512 步
    //    所以每 CLK_HZ/(BREATH_HZ*512) 拍換一階
    // --------------------------------------------------------
    localparam integer STEPS      = 2 * (1 << PWM_BITS);        // 512
    localparam integer STEP_TICKS = CLK_HZ / (BREATH_HZ * STEPS);

    function integer clog2;
        input integer v;
        integer i;
        begin
            clog2 = 1;
            for (i = v - 1; i > 1; i = i >> 1) clog2 = clog2 + 1;
        end
    endfunction

    localparam SW = clog2(STEP_TICKS);

    reg [SW-1:0] step_cnt = 0;
    reg          dir      = 1'b0;      // 0=變亮 1=變暗

    assign tick = (step_cnt == STEP_TICKS - 1);

    always @(posedge clk) begin
        if (step_cnt == STEP_TICKS - 1) begin
            step_cnt <= 0;

            //  ★ 走到頂就掉頭，走到底也掉頭
            if (dir == 1'b0) begin
                if (duty == {PWM_BITS{1'b1}}) dir  <= 1'b1;
                else                          duty <= duty + 1'b1;
            end else begin
                if (duty == 0) dir  <= 1'b0;
                else           duty <= duty - 1'b1;
            end
        end else begin
            step_cnt <= step_cnt + 1'b1;
        end
    end

endmodule

//  ---- 模擬 ----
//  iverilog -o sim.out 02_pwm.v 02_pwm_tb.v
//  vvp sim.out
//  gtkwave 02_pwm.gtkw
//
//  ---- 產生 bitstream ----
//  build.bat 02_pwm pwm
