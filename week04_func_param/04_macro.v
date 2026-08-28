// ============================================================
//  W4-4：巨集 `define 與條件編譯 `ifdef
//  重點：這些在「編譯前」就處理掉了，硬體看不到它們
// ============================================================
`timescale 1ns / 1ps

// ---------- 常數巨集 ----------
`define DATA_W    8
`define IDLE      2'b00
`define RUN       2'b01
`define DONE      2'b10

// ---------- 開關：註解掉這行，電路就變了 ----------
`define USE_FAST_ADDER

module macro_demo (
    input  wire [`DATA_W-1:0] a, b,
    input  wire [1:0]         state,
    output wire [`DATA_W-1:0] result,
    output wire               is_running
);

`ifdef USE_FAST_ADDER
    // 這一段會被編譯進去
    assign result = a + b;
`else
    // 這一段會被完全忽略，連語法都不檢查
    assign result = a - b;
`endif

    assign is_running = (state == `RUN);

endmodule
