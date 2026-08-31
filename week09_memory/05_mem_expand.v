// ============================================================
//  W9-5：記憶體的位元擴充與字組擴充    ← 課本 12.2 / 12.5
//  重點：★ 手上只有小顆記憶體，怎麼拼出大顆的？
//        位元擴充 = 把「每格變寬」   → 位址線共用，資料線併起來
//        字組擴充 = 把「格數變多」   → 資料線共用，位址線多一條當選片
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  基本單元：16 格 x 4 位元 的小 RAM
//  下面兩種擴充都只用這一種零件去拼
// ------------------------------------------------------------
module ram_16x4 (
    input  wire       clk,
    input  wire       cs,        // chip select，0 = 這顆不理你
    input  wire       we,
    input  wire [3:0] addr,
    input  wire [3:0] din,
    output wire [3:0] dout
);
    reg [3:0] mem [0:15];
    reg [3:0] dout_r;

    always @(posedge clk) begin
        if (cs && we) mem[addr] <= din;
        if (cs)       dout_r    <= mem[addr];
    end

    //  沒選到這顆的時候輸出高阻抗，才能和別顆並在同一條匯流排上
    //  ← 這就是第 3 週 11_tristate_inout 學的三態閘
    assign dout = cs ? dout_r : 4'bz;
endmodule


// ------------------------------------------------------------
//  一、位元擴充（課本 12.2.1）
//     兩顆 16x4  →  一顆 16x8
//
//     兩顆【位址線接在一起】（同時被定址到同一格），
//     資料線一顆負責高 4 位、一顆負責低 4 位，串接起來就是 8 位。
//
//        addr ─┬─→ [RAM_H] ─→ dout[7:4]
//              └─→ [RAM_L] ─→ dout[3:0]
// ------------------------------------------------------------
module ram_16x8_bitexp (
    input  wire       clk,
    input  wire       we,
    input  wire [3:0] addr,
    input  wire [7:0] din,
    output wire [7:0] dout
);
    //  ★ 位址、we、cs 全部接一樣，只有資料切兩半
    ram_16x4 hi (.clk(clk), .cs(1'b1), .we(we), .addr(addr),
                 .din(din[7:4]), .dout(dout[7:4]));

    ram_16x4 lo (.clk(clk), .cs(1'b1), .we(we), .addr(addr),
                 .din(din[3:0]), .dout(dout[3:0]));
endmodule


// ------------------------------------------------------------
//  二、字組擴充（課本 12.2.2）
//     兩顆 16x4  →  一顆 32x4
//
//     資料線併在同一條匯流排上，位址多用一位元 addr[4] 當【選片】。
//     ★ 同一時間只能有一顆 cs=1，否則就是第 3 週講的匯流排衝突。
//
//        addr[3:0] ─┬─→ [RAM_0] ─┐
//                   └─→ [RAM_1] ─┴─→ dout（共用）
//        addr[4] ──→ 解碼器 → cs0 / cs1
// ------------------------------------------------------------
module ram_32x4_wordexp (
    input  wire       clk,
    input  wire       we,
    input  wire [4:0] addr,
    input  wire [3:0] din,
    output wire [3:0] dout
);
    wire cs0, cs1;

    //  ★ 用最高位址位元做 1-to-2 解碼（就是第 3 週的 08_demux）
    //    addr[4]=0 → 選下半部；addr[4]=1 → 選上半部
    assign cs0 = ~addr[4];
    assign cs1 =  addr[4];

    //  兩顆的 dout 直接接在同一條線上 —— 靠三態閘避免打架
    ram_16x4 blk0 (.clk(clk), .cs(cs0), .we(we), .addr(addr[3:0]),
                   .din(din), .dout(dout));

    ram_16x4 blk1 (.clk(clk), .cs(cs1), .we(we), .addr(addr[3:0]),
                   .din(din), .dout(dout));
endmodule


// ------------------------------------------------------------
//  三、ROM 的擴充（課本 12.5）道理完全一樣
//     這裡用字組擴充做一顆 32 格的 ROM
// ------------------------------------------------------------
module rom_16x8 #(
    parameter [7:0] BASE = 8'h00
) (
    input  wire [3:0] addr,
    input  wire       cs,
    output wire [7:0] dout
);
    reg [7:0] rom [0:15];
    integer i;
    initial for (i = 0; i < 16; i = i + 1) rom[i] = BASE + i[7:0];

    assign dout = cs ? rom[addr] : 8'bz;
endmodule

module rom_32x8_wordexp (
    input  wire [4:0] addr,
    output wire [7:0] dout
);
    rom_16x8 #(.BASE(8'h10)) r0 (.addr(addr[3:0]), .cs(~addr[4]), .dout(dout));
    rom_16x8 #(.BASE(8'hA0)) r1 (.addr(addr[3:0]), .cs( addr[4]), .dout(dout));
endmodule


// ------------------------------------------------------------
//  把三個都包起來，方便測試
// ------------------------------------------------------------
module mem_expand (
    input  wire       clk,
    input  wire       we,

    input  wire [3:0] a4,
    input  wire [7:0] d8,
    output wire [7:0] q_bitexp,

    input  wire [4:0] a5,
    input  wire [3:0] d4,
    output wire [3:0] q_wordexp,

    output wire [7:0] q_rom
);
    ram_16x8_bitexp  u_bit  (.clk(clk), .we(we), .addr(a4), .din(d8), .dout(q_bitexp));
    ram_32x4_wordexp u_word (.clk(clk), .we(we), .addr(a5), .din(d4), .dout(q_wordexp));
    rom_32x8_wordexp u_rom  (.addr(a5), .dout(q_rom));
endmodule

//  iverilog -o sim.out 05_mem_expand.v 05_mem_expand_tb.v
//  vvp sim.out
//  gtkwave 05_mem_expand.gtkw
