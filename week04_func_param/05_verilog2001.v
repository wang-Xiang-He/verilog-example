// ============================================================
//  W4-5：Verilog 2001 增強特色         ← 課本第 13 章
//  重點：課本第 13 章有 70 頁、34 個特色，這裡挑【實務上真的會用到】
//        而且和第 4 週主題（函式／參數／屬性／組態）直接相關的做示範
//
//  課綱寫的「屬性」= 13.25 Attribute
//            「組態」= 13.1  Configuration
//  這兩個詞是課本原文，不是泛稱。
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  13.18  ANSI-style Port List
//  舊寫法（Verilog-1995）要寫兩次：先列名字，再宣告方向和型別
//     module foo (a, b, y);
//       input [7:0] a, b;
//       output [7:0] y;
//  新寫法一次寫完，就是下面這樣。本專案從頭到尾用的都是新寫法。
//
//  13.16  Explicit In-line Parameter Passing → #(.W(8)) 具名傳參數
//  13.19  Reg Declaration With Initialization → reg [7:0] r = 0;
// ------------------------------------------------------------
module v2001_demo #(
    parameter W    = 8,
    parameter MODE = "FAST"          // ★ 參數可以是字串（13.x）
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire [W-1:0]     a, b,
    input  wire [3:0]       idx,

    output wire [W-1:0]     pow_out,     // 13.8  ** 次方運算子
    output wire [3:0]       part_out,    // 13.4  索引式部分選擇 +:
    output wire [W-1:0]     const_out,   // 13.3  常數函式
    output wire [W-1:0]     md_out,      // 13.5  多維陣列
    output reg  [W-1:0]     sens_out,    // 13.10 逗號分隔的敏感度列表
    output wire             signed_ok    // 13.7  有號數運算延伸
);

    // --------------------------------------------------------
    //  13.3  Constant Function（常數函式）
    //  ★ 可以在【編譯時期】用函式算出參數值
    //    以前算 log2 只能自己手動填數字，現在可以讓工具算
    // --------------------------------------------------------
    function integer clog2;
        input integer value;
        integer i;
        begin
            clog2 = 0;
            for (i = value - 1; i > 0; i = i >> 1)
                clog2 = clog2 + 1;
        end
    endfunction

    localparam ADDR_BITS = clog2(W);     // W=8 → 3

    assign const_out = ADDR_BITS[W-1:0];

    // --------------------------------------------------------
    //  13.8  Power Operator  **
    //  以前要算次方只能自己寫迴圈，現在有運算子了
    //  ⚠️ 但只有【指數是常數】的時候才合成得出來
    // --------------------------------------------------------
    localparam [W-1:0] TWO_POW_5 = 2 ** 5;   // = 32
    assign pow_out = TWO_POW_5;

    // --------------------------------------------------------
    //  13.4  Indexed Vector Part Select   +: 和 -:
    //  ★ 這個超好用。舊寫法 a[idx+3 : idx] 是【非法】的，
    //    因為 Verilog 規定切片的上下界必須是常數。
    //    新寫法 a[idx +: 4] 意思是「從 idx 開始往上取 4 位」，
    //    起點可以是變數 —— 這才是它的價值。
    // --------------------------------------------------------
    wire [W-1:0] wide = {a[3:0], b[3:0]};
    assign part_out = wide[idx +: 4];        // 從第 idx 位開始取 4 位

    // --------------------------------------------------------
    //  13.5  Multi-dimensional Array（多維陣列）
    //  Verilog-1995 只能有一維記憶體，2001 開始可以多維
    // --------------------------------------------------------
    reg [W-1:0] table2d [0:3][0:3];
    integer r, c;
    initial begin
        for (r = 0; r < 4; r = r + 1)
            for (c = 0; c < 4; c = c + 1)
                table2d[r][c] = r[W-1:0] * 8'd16 + c[W-1:0];
    end
    assign md_out = table2d[idx[3:2]][idx[1:0]];

    // --------------------------------------------------------
    //  13.10 Comma-separated Sensitivity List
    //  13.11 Combinational Logic Sensitivity  @*
    //  舊寫法：always @(a or b or idx)      ← 漏一個就生 latch，超容易錯
    //  新寫法：always @(a, b, idx) 或直接 always @(*)
    //  ★ 一律用 @(*)，讓工具自己抓，永遠不會漏
    // --------------------------------------------------------
    always @(a, b) begin                  // 13.10 的逗號寫法
        sens_out = a ^ b;
    end

    // --------------------------------------------------------
    //  13.7  Signed Arithmetic Extension
    //  Verilog-1995 只有 integer 是有號的，reg/wire 一律無號。
    //  2001 開始 reg/wire 都可以宣告 signed，還多了 $signed/$unsigned。
    //  → 第 2 週的 07_arith_signed 用的就是這個功能
    // --------------------------------------------------------
    wire signed [W-1:0] sa = a;
    wire signed [W-1:0] sb = b;
    assign signed_ok = (sa * sb) == ($signed(a) * $signed(b));

    // --------------------------------------------------------
    //  13.23 Enhanced Conditional Compilation
    //  多了 `elsif，以前只有 `ifdef / `else / `endif
    // --------------------------------------------------------
`ifdef SPEED_MODE
    initial $display("   [編譯選項] SPEED_MODE 有開");
`elsif AREA_MODE
    initial $display("   [編譯選項] AREA_MODE 有開");
`else
    initial $display("   [編譯選項] 兩個都沒開，走預設");
`endif

endmodule


// ------------------------------------------------------------
//  13.25  Attribute（屬性）★ 課綱說的「屬性」就是這個
//
//  語法是 (* ... *)，寫在被修飾的東西【前面】。
//  它不影響電路行為，是【給綜合工具看的指示】。
//  iverilog 會把它當註解略過，yosys 則會真的照做。
//
//  常見的幾個：
//    (* keep *)              不要把這條線最佳化掉（除錯時很有用）
//    (* full_case *)         我保證 case 已經列全，不用補 latch
//    (* parallel_case *)     我保證各條件互斥，可以並聯比較
//    (* ram_style = "block" *)  這塊記憶體請用 BRAM 實作（第 9 週會用到）
// ------------------------------------------------------------
module attr_demo (
    input  wire [1:0] sel,
    input  wire [3:0] d0, d1, d2, d3,
    output reg  [3:0] y,
    output wire [3:0] kept
);

    //  ★ (* full_case, parallel_case *)：告訴工具這個 case 是完整且互斥的
    //    ⚠️ 用它要非常小心 —— 你講的如果不是真的，
    //       模擬結果和合成後的電路會【不一樣】，這是很難抓的 bug。
    (* full_case, parallel_case *)
    always @(*) begin
        case (sel)
            2'd0: y = d0;
            2'd1: y = d1;
            2'd2: y = d2;
            2'd3: y = d3;
        endcase
    end

    //  ★ (* keep *)：這條中間線平常會被最佳化掉，加了就會保留下來，
    //    綜合後還看得到，方便對波形除錯
    (* keep *) wire [3:0] debug_wire = d0 ^ d1;
    assign kept = debug_wire;

endmodule

//  iverilog -o sim.out 05_verilog2001.v 05_verilog2001_tb.v
//  vvp sim.out
//  gtkwave 05_verilog2001.gtkw
//
//  試試看加編譯選項：
//  iverilog -DSPEED_MODE -o sim.out 05_verilog2001.v 05_verilog2001_tb.v
