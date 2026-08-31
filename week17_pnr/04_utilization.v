// ============================================================
//  W17-4：資源使用率分析
//  重點：★ 晶片有多少資源？你的設計用掉多少？還能塞多少？
//
//  iCE40 HX8K 的資源：
//     ICESTORM_LC    7680 個   邏輯單元（1 個 LUT4 + 1 個 DFF）
//     ICESTORM_RAM     32 個   4Kbit 的 Block RAM
//     SB_IO           206 支   輸出入腳位
//     SB_GB             8 個   全域緩衝（時脈網路）
//     ICESTORM_PLL      2 個   鎖相迴路（倍頻用）
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  一個大小可調的設計：N 個並聯的乘加器
//  ★ 改 N 就能看到使用率怎麼跟著長，以及【什麼時候會塞不下】
// ------------------------------------------------------------
module mac_array #(
    parameter N = 4
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  a, b,
    output wire [15:0] result
);
    wire [15:0] partial [0:N-1];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : mac
            reg [15:0] acc;
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) acc <= 0;
                //  每一路用不同的偏移量，避免被最佳化成同一個東西
                else        acc <= acc + ((a + i[7:0]) * (b + i[7:0]));
            end
            assign partial[i] = acc;
        end
    endgenerate

    //  把所有路加起來（用樹狀結構）
    reg [15:0] total;
    integer k;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) total <= 0;
        else begin
            total = 0;
            for (k = 0; k < N; k = k + 1) total = total + partial[k];
        end
    end
    assign result = total;
endmodule


// ------------------------------------------------------------
//  三種大小，給 .bat 分別綜合比較
// ------------------------------------------------------------
module util_small (
    input wire clk, rst_n, input wire [7:0] a, b, output wire [15:0] result
);
    mac_array #(.N(2))  u (.clk(clk), .rst_n(rst_n), .a(a), .b(b), .result(result));
endmodule

module util_medium (
    input wire clk, rst_n, input wire [7:0] a, b, output wire [15:0] result
);
    mac_array #(.N(8))  u (.clk(clk), .rst_n(rst_n), .a(a), .b(b), .result(result));
endmodule

module util_large (
    input wire clk, rst_n, input wire [7:0] a, b, output wire [15:0] result
);
    mac_array #(.N(32)) u (.clk(clk), .rst_n(rst_n), .a(a), .b(b), .result(result));
endmodule


// ------------------------------------------------------------
//  ★ 對照組：一塊記憶體 —— 看它會不會被推斷成 Block RAM
//    （第 9 週學的「怎麼寫才會被綜合成 BRAM」）
// ------------------------------------------------------------
module util_bram (
    input  wire        clk,
    input  wire        we,
    input  wire [8:0]  addr,
    input  wire [7:0]  din,
    output reg  [7:0]  dout
);
    reg [7:0] mem [0:511];

    //  ★ 這種寫法（同步讀 + 同步寫）會被推斷成 BRAM
    always @(posedge clk) begin
        if (we) mem[addr] <= din;
        dout <= mem[addr];
    end
endmodule


// ------------------------------------------------------------
//  ⚠️ 對照：同樣的記憶體，但用【非同步讀】
//    → 這樣寫【不會】變成 BRAM，會被硬塞成一大堆 LUT
// ------------------------------------------------------------
module util_lutram (
    input  wire        clk,
    input  wire        we,
    input  wire [8:0]  addr,
    input  wire [7:0]  din,
    output wire [7:0]  dout
);
    reg [7:0] mem [0:511];

    always @(posedge clk) begin
        if (we) mem[addr] <= din;
    end

    //  ★ 非同步讀 —— BRAM 硬體做不到這件事，只好用 LUT 拼
    assign dout = mem[addr];
endmodule

//  ---- 分析使用率 ----
//  04_utilization.bat
