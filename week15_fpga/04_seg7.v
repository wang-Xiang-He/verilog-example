// ============================================================
//  W15-4：四位數七段顯示器（掃描顯示）
//  重點：★ 四位數要 4x8 = 32 支腳，但板子只有 8+4 = 12 支可用。
//        解法：一次只點亮一位，快速輪流掃 —— 靠視覺暫留騙過眼睛。
//
//        這是「用時間換空間」最經典的例子，
//        跟第 12 週「用延遲換吞吐量」是同一種思路。
// ============================================================
`timescale 1ns / 1ps

module seg7_top #(
    parameter CLK_HZ  = 12_000_000,
    parameter SCAN_HZ = 1000            // 每位數每秒掃 1000/4 = 250 次
) (
    input  wire       clk,
    output wire [7:0] seg,        // {dp,g,f,e,d,c,b,a}
    output wire [3:0] digit,      // 位數選擇（低準位有效）
    output wire       tick
);

    function integer clog2;
        input integer v;
        integer i;
        begin
            clog2 = 1;
            for (i = v - 1; i > 1; i = i >> 1) clog2 = clog2 + 1;
        end
    endfunction

    // ========================================================
    //  一、掃描用的分頻器
    //  ★ 掃描頻率要夠快（>60Hz x 位數），否則會看到閃爍
    // ========================================================
    localparam integer SCAN_TICKS = CLK_HZ / SCAN_HZ;
    localparam SCW = clog2(SCAN_TICKS);

    reg [SCW-1:0] scan_cnt = 0;
    reg [1:0]     scan_idx = 0;       // 現在輪到第幾位

    assign tick = (scan_cnt == SCAN_TICKS - 1);

    always @(posedge clk) begin
        if (scan_cnt == SCAN_TICKS - 1) begin
            scan_cnt <= 0;
            scan_idx <= scan_idx + 1'b1;
        end else begin
            scan_cnt <= scan_cnt + 1'b1;
        end
    end

    // ========================================================
    //  二、要顯示的數字（這裡做一個每秒加一的計數器）
    // ========================================================
    localparam integer SEC_TICKS = CLK_HZ;
    localparam SW = clog2(SEC_TICKS);

    reg [SW-1:0]  sec_cnt = 0;
    reg [13:0]    value   = 0;       // 0 ~ 9999

    always @(posedge clk) begin
        if (sec_cnt == SEC_TICKS - 1) begin
            sec_cnt <= 0;
            value   <= (value == 14'd9999) ? 14'd0 : (value + 1'b1);
        end else begin
            sec_cnt <= sec_cnt + 1'b1;
        end
    end

    // ========================================================
    //  三、把二進位拆成四個十進位位數
    //
    //  ⚠️ 除法和取餘數【都會合成出很大的電路】。
    //     這裡為了範例好懂還是用了，但實務上會改用
    //     「雙重高低法 (Double Dabble)」演算法，只用位移和加法。
    //     練習 3 會叫你改。
    // ========================================================
    wire [3:0] d0 =  value        % 10;    // 個位
    wire [3:0] d1 = (value / 10)  % 10;    // 十位
    wire [3:0] d2 = (value / 100) % 10;    // 百位
    wire [3:0] d3 = (value / 1000)% 10;    // 千位

    //  ★ 依掃描位置挑出這一輪要顯示的數字
    reg [3:0] cur_digit;
    always @(*) begin
        case (scan_idx)
            2'd0: cur_digit = d0;
            2'd1: cur_digit = d1;
            2'd2: cur_digit = d2;
            2'd3: cur_digit = d3;
        endcase
    end

    // ========================================================
    //  四、七段解碼（第 8 週期中考第 1 題）
    // ========================================================
    reg [6:0] seg_pattern;
    always @(*) begin
        case (cur_digit)
            4'd0: seg_pattern = 7'b0111111;
            4'd1: seg_pattern = 7'b0000110;
            4'd2: seg_pattern = 7'b1011011;
            4'd3: seg_pattern = 7'b1001111;
            4'd4: seg_pattern = 7'b1100110;
            4'd5: seg_pattern = 7'b1101101;
            4'd6: seg_pattern = 7'b1111101;
            4'd7: seg_pattern = 7'b0000111;
            4'd8: seg_pattern = 7'b1111111;
            4'd9: seg_pattern = 7'b1101111;
            default: seg_pattern = 7'b0000000;
        endcase
    end

    //  ⚠️ 共陽極顯示器要【反相】才會亮，共陰極不用。
    //     這裡假設共陰極（1 = 亮）。接錯的話會變成負片效果。
    assign seg = {1'b0, seg_pattern};      // 最高位是小數點，這裡不用

    // ========================================================
    //  五、位數選擇
    //  ★ 一次只有一位是 0（低準位有效），其他都是 1
    // ========================================================
    reg [3:0] digit_r;
    always @(*) begin
        digit_r = 4'b1111;
        digit_r[scan_idx] = 1'b0;
    end
    assign digit = digit_r;

endmodule

//  ---- 模擬 ----
//  iverilog -o sim.out 04_seg7.v 04_seg7_tb.v
//  vvp sim.out
//  gtkwave 04_seg7.gtkw
//
//  ---- 產生 bitstream ----
//  build.bat 04_seg7 seg7_top
