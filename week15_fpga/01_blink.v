// ============================================================
//  W15-1：LED 一秒閃一次                ← 課本 2.3 / 2.5（但課本用 Vivado）
//  重點：★ 這是第一個【真的會產生 bitstream】的設計
//        前 14 週都在模擬，這週開始產出可以燒進晶片的檔案
//
//  ⚠️ 工具落差：課本整整 60 頁在教 Xilinx Vivado 的操作介面。
//     本專案用 OSS CAD Suite：yosys → nextpnr-ice40 → icepack。
//     觀念完全相同（綜合→佈局繞線→產生位元流），只是指令不同。
// ============================================================
`timescale 1ns / 1ps

module blink #(
    //  ★ 板子的時脈頻率。iCE40 開發板常見的是 12MHz。
    //    模擬時把它改小，才不用等一億拍。
    parameter CLK_HZ = 12_000_000,
    parameter BLINK_HZ = 1
) (
    input  wire clk,
    output wire led,
    output wire led_fast,      // 快閃，方便肉眼確認有在動
    output wire heartbeat      // 呼吸用的 tick（給 02_pwm 參考）
);

    //  ---- 算出要數幾下 ----
    //  ★ localparam 而不是 parameter：這是【推導出來】的值
    //    12_000_000 / 2 = 6_000_000 → 數到這個數就翻一次，剛好 1Hz
    localparam integer HALF_PERIOD = CLK_HZ / (2 * BLINK_HZ);

    //  ★ 位元寬度也要算出來，不能寫死
    //    寫死成 [31:0] 的話，改 CLK_HZ 就可能不夠用或浪費
    function integer clog2;
        input integer v;
        integer i;
        begin
            clog2 = 1;
            for (i = v - 1; i > 1; i = i >> 1) clog2 = clog2 + 1;
        end
    endfunction

    localparam CW = clog2(HALF_PERIOD);

    reg [CW-1:0] cnt = 0;
    reg          led_r = 0;

    //  ★ 注意這裡【沒有 reset】。
    //    FPGA 上電時正反器會被 bitstream 設成初始值（上面的 = 0），
    //    所以 LED 閃爍這種東西可以省掉 reset 線。
    //    ⚠️ 但這招【只在 FPGA 有效】，ASIC 一定要有 reset。
    always @(posedge clk) begin
        if (cnt == HALF_PERIOD - 1) begin
            cnt   <= 0;
            led_r <= ~led_r;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end

    assign led = led_r;

    //  ★ 免費的額外頻率：直接拿計數器的高位元
    //    （第 3 週 15_freq_div 學的「除以 2 的次方不用做電路」）
    assign led_fast  = cnt[CW-1];
    assign heartbeat = (cnt == HALF_PERIOD - 1);

endmodule

//  ---- 模擬（用很小的 CLK_HZ）----
//  iverilog -o sim.out 01_blink.v 01_blink_tb.v
//  vvp sim.out
//  gtkwave 01_blink.gtkw
//
//  ---- ★ 產生 bitstream ----
//  build.bat 01_blink blink
