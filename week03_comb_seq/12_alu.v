// ============================================================
//  W3-12：簡易算術邏輯運算單元 (ALU)   ← 課本 8.2
//  重點：把前面學的 case、加減、比較、位移全部裝進一顆電路
//        ★ 第 10 週會把這顆【拆成三個子模組】，看階層式設計怎麼做
// ============================================================
`timescale 1ns / 1ps

module alu (
    input  wire [7:0] a, b,
    input  wire [3:0] op,

    output reg  [7:0] y,
    output reg        carry,     // 進位／借位
    output wire       zero,      // 結果是不是 0
    output wire       neg        // 結果的最高位（當成有號數看時的正負號）
);

    //  ---- 用 localparam 把操作碼取名字 ----
    //  ★ 課本 11.4.3「善用常數」：不要在 case 裡直接寫 4'd0、4'd1
    //    以後改編碼只要改這裡，不用去翻 case
    localparam OP_ADD = 4'd0,
               OP_SUB = 4'd1,
               OP_AND = 4'd2,
               OP_OR  = 4'd3,
               OP_XOR = 4'd4,
               OP_NOT = 4'd5,
               OP_SHL = 4'd6,   // 邏輯左移
               OP_SHR = 4'd7,   // 邏輯右移
               OP_SAR = 4'd8,   // 算術右移（補符號位）
               OP_CMP = 4'd9,   // 比較：a>b 給 1
               OP_INC = 4'd10,
               OP_DEC = 4'd11,
               OP_PASSA = 4'd12,
               OP_PASSB = 4'd13;

    //  多算一位，用來接進位／借位
    reg [8:0] tmp;

    always @(*) begin
        //  ★ 先給預設值，兩個輸出都要給 —— 少給一個就生 latch
        tmp   = 9'd0;
        y     = 8'd0;
        carry = 1'b0;

        case (op)
            OP_ADD: begin tmp = {1'b0,a} + {1'b0,b}; y = tmp[7:0]; carry = tmp[8]; end
            OP_SUB: begin tmp = {1'b0,a} - {1'b0,b}; y = tmp[7:0]; carry = tmp[8]; end
            OP_AND: y = a & b;
            OP_OR:  y = a | b;
            OP_XOR: y = a ^ b;
            OP_NOT: y = ~a;
            OP_SHL: begin y = a << 1;          carry = a[7]; end   // 移出去的那位接進位
            OP_SHR: begin y = a >> 1;          carry = a[0]; end
            OP_SAR: begin y = $signed(a) >>> 1; carry = a[0]; end
            OP_CMP: y = (a > b) ? 8'd1 : 8'd0;
            OP_INC: begin tmp = {1'b0,a} + 9'd1; y = tmp[7:0]; carry = tmp[8]; end
            OP_DEC: begin tmp = {1'b0,a} - 9'd1; y = tmp[7:0]; carry = tmp[8]; end
            OP_PASSA: y = a;
            OP_PASSB: y = b;
            default:  y = 8'd0;     // ★ default 一定要寫
        endcase
    end

    //  旗標用 assign 拉出來，比塞進 case 裡乾淨
    assign zero = ~|y;      // 縮減 NOR：y 全 0 才是 1
    assign neg  = y[7];

endmodule

//  iverilog -o sim.out 12_alu.v 12_alu_tb.v
//  vvp sim.out
//  gtkwave 12_alu.gtkw
