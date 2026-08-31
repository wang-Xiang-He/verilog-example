// ============================================================
//  期末專題 第 1 題：UART 收發器 —— 解答
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  鮑率產生器
// ------------------------------------------------------------
module baud_gen #(
    parameter TICKS = 104
) (
    input  wire clk,
    input  wire rst_n,
    input  wire en,
    output wire tick
);
    function integer clog2;
        input integer v; integer i;
        begin clog2 = 1; for (i = v-1; i > 1; i = i >> 1) clog2 = clog2 + 1; end
    endfunction

    localparam W = clog2(TICKS);
    reg [W-1:0] cnt;

    assign tick = en && (cnt == TICKS - 1);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)        cnt <= 0;
        else if (!en)      cnt <= 0;
        else if (tick)     cnt <= 0;
        else               cnt <= cnt + 1'b1;
    end
endmodule


// ------------------------------------------------------------
//  發送器
// ------------------------------------------------------------
module uart_tx #(
    parameter TICKS = 104
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       send,
    input  wire [7:0] data,
    output reg        tx,
    output wire       busy
);
    localparam S_IDLE = 2'd0, S_START = 2'd1, S_DATA = 2'd2, S_STOP = 2'd3;

    reg [1:0] state, next_state;
    reg [2:0] bit_idx;
    reg [7:0] sh;

    assign busy = (state != S_IDLE);

    wire tick;
    baud_gen #(.TICKS(TICKS)) u_baud (
        .clk(clk), .rst_n(rst_n), .en(busy), .tick(tick));

    //  第 1 段：狀態暫存器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= S_IDLE;
        else        state <= next_state;
    end

    //  第 2 段：下一個狀態
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE:  if (send)                         next_state = S_START;
            S_START: if (tick)                         next_state = S_DATA;
            S_DATA:  if (tick && bit_idx == 3'd7)      next_state = S_STOP;
            S_STOP:  if (tick)                         next_state = S_IDLE;
            default:                                   next_state = S_IDLE;
        endcase
    end

    //  資料路徑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sh <= 8'd0; bit_idx <= 3'd0;
        end else begin
            case (state)
                S_IDLE: begin
                    bit_idx <= 3'd0;
                    if (send) sh <= data;
                end
                S_DATA: if (tick) begin
                    sh      <= {1'b0, sh[7:1]};    // LSB first
                    bit_idx <= bit_idx + 1'b1;
                end
                default: ;
            endcase
        end
    end

    //  ★ tx 上正反器，避免毛刺
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) tx <= 1'b1;
        else case (state)
            S_IDLE:  tx <= 1'b1;
            S_START: tx <= 1'b0;
            S_DATA:  tx <= sh[0];
            S_STOP:  tx <= 1'b1;
            default: tx <= 1'b1;
        endcase
    end
endmodule


// ------------------------------------------------------------
//  接收器
// ------------------------------------------------------------
module uart_rx #(
    parameter TICKS = 104
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,
    output reg  [7:0] data_out,
    output reg        valid,
    output reg        frame_err
);
    function integer clog2;
        input integer v; integer i;
        begin clog2 = 1; for (i = v-1; i > 1; i = i >> 1) clog2 = clog2 + 1; end
    endfunction

    localparam W = clog2(TICKS);

    localparam S_IDLE = 2'd0, S_START = 2'd1, S_DATA = 2'd2, S_STOP = 2'd3;

    //  ★ 兩級同步器：rx 是外部非同步訊號
    reg rx_s0, rx_s1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin rx_s0 <= 1'b1; rx_s1 <= 1'b1; end
        else        begin rx_s0 <= rx;   rx_s1 <= rx_s0; end
    end

    reg [1:0]   state;
    reg [W-1:0] cnt;
    reg [2:0]   bit_idx;
    reg [7:0]   sh;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            cnt       <= 0;
            bit_idx   <= 3'd0;
            sh        <= 8'd0;
            data_out  <= 8'd0;
            valid     <= 1'b0;
            frame_err <= 1'b0;
        end else begin
            valid     <= 1'b0;      // 這兩條只高一拍
            frame_err <= 1'b0;

            case (state)
                //  等起始位元的下降緣
                S_IDLE: begin
                    cnt     <= 0;
                    bit_idx <= 0;
                    if (rx_s1 == 1'b0) state <= S_START;
                end

                //  ★★ 等半個位元時間，對齊到起始位元的【中央】
                S_START: begin
                    if (cnt == (TICKS/2) - 1) begin
                        cnt <= 0;
                        //  中央再確認一次真的是 0（濾掉雜訊造成的假起始）
                        if (rx_s1 == 1'b0) state <= S_DATA;
                        else               state <= S_IDLE;
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end

                //  之後每隔一個完整位元時間取樣一次
                //  → 每次都會落在位元中央
                S_DATA: begin
                    if (cnt == TICKS - 1) begin
                        cnt <= 0;
                        sh  <= {rx_s1, sh[7:1]};      // LSB first
                        if (bit_idx == 3'd7) state   <= S_STOP;
                        else                 bit_idx <= bit_idx + 1'b1;
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end

                //  檢查停止位元
                S_STOP: begin
                    if (cnt == TICKS - 1) begin
                        cnt      <= 0;
                        data_out <= sh;
                        valid    <= 1'b1;
                        if (rx_s1 != 1'b1) frame_err <= 1'b1;
                        state    <= S_IDLE;
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end
            endcase
        end
    end
endmodule
