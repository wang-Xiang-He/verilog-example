// ============================================================
//  W3-15：除頻電路                    ← 課本 9.4
//  重點：★ 除以 2 的次方 = 直接拿計數器的某一位當時脈，不用任何邏輯
//        ★ 除以奇數要「用雙邊緣湊」，這是考試的重點
// ============================================================
`timescale 1ns / 1ps

module freq_div (
    input  wire clk,
    input  wire rst_n,

    // ---- 一、除以 2 的次方：計數器的位元直接就是答案 ----
    output wire div2,        // 50% 工作週期
    output wire div4,
    output wire div8,
    output wire div16,

    // ---- 二、除以任意整數 N（這裡 N=5），工作週期不是 50% ----
    output reg  div5,

    // ---- 三、★ 除以奇數又要 50% 工作週期（N=5）----
    output wire div5_50
);

    // --------------------------------------------------------
    //  一、除以 2 的次方
    //  一個 4 位元計數器，cnt[0] 就是除 2、cnt[1] 就是除 4 ...
    //  ★ 這是「免費」的除頻器：一顆計數器就給你四種頻率，不用多做電路
    // --------------------------------------------------------
    reg [3:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) cnt <= 4'd0;
        else        cnt <= cnt + 4'd1;
    end

    assign div2  = cnt[0];
    assign div4  = cnt[1];
    assign div8  = cnt[2];
    assign div16 = cnt[3];

    // --------------------------------------------------------
    //  二、除以 5（工作週期 = 1/5，不是 50%）
    //  最單純：數到 4 就發一個一拍寬的脈衝
    //  ★ 這種「一拍寬的脈衝」在實務上超常用，叫做 tick 或 enable pulse
    //    第 15 週的 LED 閃爍、UART 鮑率產生器都是用這招
    // --------------------------------------------------------
    reg [2:0] cnt5;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt5 <= 3'd0;
            div5 <= 1'b0;
        end else if (cnt5 == 3'd4) begin
            cnt5 <= 3'd0;
            div5 <= 1'b1;         // 只高一拍
        end else begin
            cnt5 <= cnt5 + 3'd1;
            div5 <= 1'b0;
        end
    end

    // --------------------------------------------------------
    //  三、★ 除以 5 而且要 50% 工作週期
    //
    //  問題：5 個時脈週期沒辦法平均分成兩半（2.5 : 2.5）
    //  解法：做兩個除 5 電路，一個用【上升緣】、一個用【下降緣】，
    //        兩個差半個週期，再把它們 OR 起來 → 就湊出 2.5 個週期的高電位
    //
    //  這是課本和考試都愛考的經典技巧
    // --------------------------------------------------------
    reg [2:0] cnt_p, cnt_n;
    reg       out_p, out_n;

    // 上升緣那一半
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_p <= 3'd0;
            out_p <= 1'b0;
        end else begin
            cnt_p <= (cnt_p == 3'd4) ? 3'd0 : cnt_p + 3'd1;
            //  0,1 高；2,3,4 低  → 5 拍裡高 2 拍
            out_p <= (cnt_p < 3'd2);
        end
    end

    // 下降緣那一半（跟上面一模一樣，只是換成 negedge）
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_n <= 3'd0;
            out_n <= 1'b0;
        end else begin
            cnt_n <= (cnt_n == 3'd4) ? 3'd0 : cnt_n + 3'd1;
            out_n <= (cnt_n < 3'd2);
        end
    end

    //  兩個一 OR，就補出中間那半拍 → 高 2.5 拍、低 2.5 拍
    assign div5_50 = out_p | out_n;

endmodule

//  iverilog -o sim.out 15_freq_div.v 15_freq_div_tb.v
//  vvp sim.out
//  gtkwave 15_freq_div.gtkw
