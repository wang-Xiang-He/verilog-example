// ============================================================
//  期末專題 第 3 題：VGA 訊號產生器 —— 解答
// ============================================================
`timescale 1ns / 1ps

module vga_sync #(
    parameter H_VISIBLE = 640,
    parameter H_FRONT   = 16,
    parameter H_SYNC    = 96,
    parameter H_BACK    = 48,
    parameter V_VISIBLE = 480,
    parameter V_FRONT   = 10,
    parameter V_SYNC    = 2,
    parameter V_BACK    = 33
) (
    input  wire       clk,
    input  wire       rst_n,
    output wire       hsync,
    output wire       vsync,
    output wire       video_on,
    output wire [9:0] pixel_x,
    output wire [9:0] pixel_y,
    output wire       frame_start
);
    localparam H_TOTAL = H_VISIBLE + H_FRONT + H_SYNC + H_BACK;   // 800
    localparam V_TOTAL = V_VISIBLE + V_FRONT + V_SYNC + V_BACK;   // 525

    //  同步脈衝的起訖位置
    localparam H_SYNC_START = H_VISIBLE + H_FRONT;                // 656
    localparam H_SYNC_END   = H_VISIBLE + H_FRONT + H_SYNC - 1;   // 751
    localparam V_SYNC_START = V_VISIBLE + V_FRONT;                // 490
    localparam V_SYNC_END   = V_VISIBLE + V_FRONT + V_SYNC - 1;   // 491

    reg [9:0] h_cnt, v_cnt;

    //  ---- 水平計數器：每個像素時脈 +1 ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)                     h_cnt <= 10'd0;
        else if (h_cnt == H_TOTAL - 1)  h_cnt <= 10'd0;
        else                            h_cnt <= h_cnt + 1'b1;
    end

    //  ---- 垂直計數器：★ 只在一行掃完的那一拍才 +1 ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)                          v_cnt <= 10'd0;
        else if (h_cnt == H_TOTAL - 1) begin
            if (v_cnt == V_TOTAL - 1)        v_cnt <= 10'd0;
            else                             v_cnt <= v_cnt + 1'b1;
        end
    end

    //  ★ 低準位有效：在同步區間內輸出 0
    assign hsync = ~((h_cnt >= H_SYNC_START) && (h_cnt <= H_SYNC_END));
    assign vsync = ~((v_cnt >= V_SYNC_START) && (v_cnt <= V_SYNC_END));

    assign video_on = (h_cnt < H_VISIBLE) && (v_cnt < V_VISIBLE);

    assign pixel_x = h_cnt;
    assign pixel_y = v_cnt;

    assign frame_start = (h_cnt == 10'd0) && (v_cnt == 10'd0);

endmodule


// ------------------------------------------------------------
//  棋盤格圖樣
// ------------------------------------------------------------
module vga_pattern (
    input  wire       clk,
    input  wire       rst_n,
    output wire       hsync,
    output wire       vsync,
    output wire [2:0] rgb
);
    wire       video_on;
    wire [9:0] px, py;

    vga_sync u_sync (
        .clk(clk), .rst_n(rst_n),
        .hsync(hsync), .vsync(vsync),
        .video_on(video_on), .pixel_x(px), .pixel_y(py),
        .frame_start()
    );

    //  ★ 不用除法的作法：
    //    80 = 64 + 16。與其算 px/80，不如觀察到
    //    我們只需要「格子編號的最低位」（決定黑白），
    //    所以可以用一個計數器：每 80 像素翻一次。
    //
    //    但為了讓答案好懂，這裡先用最直觀的除法寫，
    //    下面再附上不用除法的版本。
    wire [3:0] cell_x = px / 80;
    wire [3:0] cell_y = py / 80;
    wire       dark   = (cell_x[0] ^ cell_y[0]);

    assign rgb = video_on ? (dark ? 3'b000 : 3'b111) : 3'b000;

endmodule


// ------------------------------------------------------------
//  ★ 加分版：完全不用除法的棋盤格
//    用兩個「每 80 個就翻一次」的旗標，直接 XOR
// ------------------------------------------------------------
module vga_pattern_nodiv (
    input  wire       clk,
    input  wire       rst_n,
    output wire       hsync,
    output wire       vsync,
    output wire [2:0] rgb
);
    wire       video_on, frame_start;
    wire [9:0] px, py;

    vga_sync u_sync (
        .clk(clk), .rst_n(rst_n),
        .hsync(hsync), .vsync(vsync),
        .video_on(video_on), .pixel_x(px), .pixel_y(py),
        .frame_start(frame_start)
    );

    //  水平：每 80 個像素把 cx 翻一次
    reg [6:0] hx;        // 0~79
    reg       cx;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hx <= 0; cx <= 0;
        end else if (px == 10'd0) begin
            hx <= 0; cx <= 0;              // 每行開頭重來
        end else if (hx == 7'd79) begin
            hx <= 0; cx <= ~cx;
        end else begin
            hx <= hx + 1'b1;
        end
    end

    //  垂直：每 80 條掃描線把 cy 翻一次
    reg [6:0] vy;
    reg       cy;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vy <= 0; cy <= 0;
        end else if (frame_start) begin
            vy <= 0; cy <= 0;              // 每張畫面開頭重來
        end else if (px == 10'd0) begin    // 換行的那一拍
            if (vy == 7'd79) begin
                vy <= 0; cy <= ~cy;
            end else begin
                vy <= vy + 1'b1;
            end
        end
    end

    assign rgb = video_on ? ((cx ^ cy) ? 3'b000 : 3'b111) : 3'b000;

endmodule
