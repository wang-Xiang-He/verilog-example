// ============================================================
//  W15-5：UART 發送器
//  重點：★ 本課程第一個【和外界通訊】的電路
//        接上 USB 轉序列埠，用 PuTTY 就能看到 FPGA 送出來的字
//
//  UART 的格式（8N1，最常見的設定）：
//
//     閒置  起始   d0  d1  d2  d3  d4  d5  d6  d7   停止  閒置
//     ▔▔▔▔╲___╱▔╲__╱▔▔╲_╱▔▔▔▔╲___╱▔▔▔▔▔▔▔▔▔
//          低一位  ← 先送最低位 (LSB first) →   高一位
//
//     每一位持續 1/鮑率 秒。9600 bps → 每位 104.17 微秒。
//
//  ★ 這顆就是第 3 週 14_shift_4types 學的 PISO（並進串出）
//    加上一台狀態機控制時序。
// ============================================================
`timescale 1ns / 1ps

module uart_tx #(
    parameter CLK_HZ = 12_000_000,
    parameter BAUD   = 115200
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       send,        // 拉高一拍就送出 data
    input  wire [7:0] data,
    output reg        tx,          // ★ 接到序列埠的線
    output wire       busy
);

    // ========================================================
    //  一、鮑率產生器
    //  ★ 每 CLK_HZ/BAUD 拍送一位
    //    12MHz / 115200 = 104.17 → 取 104
    //
    //  ⚠️ 誤差要算：104 拍 = 8.667us，理想是 8.681us，誤差 0.16%。
    //     UART 容許約 ±2% 的誤差（10 位元累積下來不能超過半位元），
    //     所以 0.16% 完全沒問題。
    //     但如果你用 12MHz 去湊 921600 bps：12M/921600 = 13.02 → 13，
    //     誤差 0.16% 還好；湊 1M bps 就會變成 12，誤差 0% 但更快了。
    //     總之【一定要算誤差】，不能隨便取整數。
    // ========================================================
    localparam integer BAUD_TICKS = CLK_HZ / BAUD;

    function integer clog2;
        input integer v;
        integer i;
        begin
            clog2 = 1;
            for (i = v - 1; i > 1; i = i >> 1) clog2 = clog2 + 1;
        end
    endfunction

    localparam BW = clog2(BAUD_TICKS);

    reg [BW-1:0] baud_cnt;
    wire         baud_tick = (baud_cnt == BAUD_TICKS - 1);

    // ========================================================
    //  二、狀態機（三段式寫法，第 6 週學的）
    // ========================================================
    localparam S_IDLE  = 2'd0,
               S_START = 2'd1,
               S_DATA  = 2'd2,
               S_STOP  = 2'd3;

    reg [1:0] state, next_state;
    reg [2:0] bit_idx;         // 現在送到第幾位（0~7）
    reg [7:0] shift_reg;       // ★ PISO 移位暫存器

    assign busy = (state != S_IDLE);

    //  ---- 第 1 段：狀態暫存器 ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= S_IDLE;
        else        state <= next_state;
    end

    //  ---- 第 2 段：下一個狀態 ----
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE:  if (send)                            next_state = S_START;
            S_START: if (baud_tick)                       next_state = S_DATA;
            S_DATA:  if (baud_tick && bit_idx == 3'd7)    next_state = S_STOP;
            S_STOP:  if (baud_tick)                       next_state = S_IDLE;
            default:                                      next_state = S_IDLE;
        endcase
    end

    //  ---- 鮑率計數器：只有在傳送中才需要數 ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)                 baud_cnt <= 0;
        else if (state == S_IDLE)   baud_cnt <= 0;
        else if (baud_tick)         baud_cnt <= 0;
        else                        baud_cnt <= baud_cnt + 1'b1;
    end

    //  ---- 資料路徑：移位暫存器 + 位元計數 ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 8'd0;
            bit_idx   <= 3'd0;
        end else begin
            case (state)
                S_IDLE: begin
                    bit_idx <= 3'd0;
                    if (send) shift_reg <= data;     // 並列載入
                end
                S_DATA: begin
                    if (baud_tick) begin
                        //  ★ 往右推一位，最低位先送出去（LSB first）
                        shift_reg <= {1'b0, shift_reg[7:1]};
                        bit_idx   <= bit_idx + 1'b1;
                    end
                end
                default: ;
            endcase
        end
    end

    //  ---- 輸出：tx 這條線在各狀態該送什麼 ----
    //  ⚠️ tx 一定要上正反器，不能用組合邏輯 ——
    //     組合邏輯會有毛刺（第 7 週 02_glitch），
    //     一個毛刺就會被對方解讀成起始位元，整包資料錯掉。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) tx <= 1'b1;                 // 閒置時是高電位
        else begin
            case (state)
                S_IDLE:  tx <= 1'b1;
                S_START: tx <= 1'b0;            // 起始位元：低
                S_DATA:  tx <= shift_reg[0];    // 資料位元
                S_STOP:  tx <= 1'b1;            // 停止位元：高
                default: tx <= 1'b1;
            endcase
        end
    end

endmodule


// ------------------------------------------------------------
//  頂層：每秒自動送一個字元出去
//  接上 USB 轉序列埠，用 PuTTY 開 115200 8N1 就看得到
// ------------------------------------------------------------
module uart_tx_top #(
    parameter CLK_HZ = 12_000_000,
    parameter BAUD   = 115200
) (
    input  wire clk,
    output wire uart_tx,
    output wire busy,
    output wire led
);
    localparam integer SEC_TICKS = CLK_HZ;

    function integer clog2;
        input integer v;
        integer i;
        begin
            clog2 = 1;
            for (i = v - 1; i > 1; i = i >> 1) clog2 = clog2 + 1;
        end
    endfunction

    localparam SW = clog2(SEC_TICKS);

    reg [SW-1:0] sec_cnt = 0;
    reg [7:0]    ch      = 8'h41;      // 'A'
    reg          send    = 1'b0;

    always @(posedge clk) begin
        send <= 1'b0;
        if (sec_cnt == SEC_TICKS - 1) begin
            sec_cnt <= 0;
            send    <= 1'b1;
            //  A B C ... Z 循環
            ch <= (ch == 8'h5A) ? 8'h41 : (ch + 1'b1);
        end else begin
            sec_cnt <= sec_cnt + 1'b1;
        end
    end

    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
        .clk(clk), .rst_n(1'b1),
        .send(send), .data(ch),
        .tx(uart_tx), .busy(busy)
    );

    assign led = busy;
endmodule

//  ---- 模擬 ----
//  iverilog -o sim.out 05_uart_tx.v 05_uart_tx_tb.v
//  vvp sim.out
//  gtkwave 05_uart_tx.gtkw
//
//  ---- 產生 bitstream ----
//  build.bat 05_uart_tx uart_tx_top
