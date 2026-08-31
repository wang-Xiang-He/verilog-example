// ============================================================
//  W10-1：把 ALU 拆成子模組            ← 課本 3.7（PDF p.139-143）
//  重點：★ 對照第 3 週的 12_alu —— 【同樣的功能】，一個平的、一個分層的
//        比較「一顆大模組」和「四顆小模組」差在哪
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  子模組 1：算術單元
//  只負責加減，不知道外面有誰、也不在乎
// ------------------------------------------------------------
module alu_arith #(
    parameter W = 8
) (
    input  wire [W-1:0] a, b,
    input  wire         sub,        // 0=加 1=減
    output wire [W-1:0] result,
    output wire         carry
);
    //  ★ 加減共用一顆加法器的經典寫法：
    //    減法 = 加上 b 的二補數 = 加上 (~b + 1)
    //    所以把 b 依 sub 取反、再把 sub 當進位輸入送進去
    wire [W-1:0] b_in = sub ? ~b : b;
    wire [W:0]   sum  = {1'b0, a} + {1'b0, b_in} + {{W{1'b0}}, sub};

    assign result = sum[W-1:0];
    assign carry  = sum[W];
endmodule


// ------------------------------------------------------------
//  子模組 2：邏輯單元
// ------------------------------------------------------------
module alu_logic #(
    parameter W = 8
) (
    input  wire [W-1:0] a, b,
    input  wire [1:0]   op,         // 0=AND 1=OR 2=XOR 3=NOT a
    output reg  [W-1:0] result
);
    always @(*) begin
        case (op)
            2'd0: result = a & b;
            2'd1: result = a | b;
            2'd2: result = a ^ b;
            2'd3: result = ~a;
            default: result = {W{1'b0}};
        endcase
    end
endmodule


// ------------------------------------------------------------
//  子模組 3：位移單元
// ------------------------------------------------------------
module alu_shift #(
    parameter W = 8
) (
    input  wire [W-1:0] a,
    input  wire [1:0]   op,         // 0=左移 1=邏輯右移 2=算術右移 3=不動
    output reg  [W-1:0] result
);
    always @(*) begin
        case (op)
            2'd0: result = a << 1;
            2'd1: result = a >> 1;
            2'd2: result = $signed(a) >>> 1;
            2'd3: result = a;
            default: result = {W{1'b0}};
        endcase
    end
endmodule


// ------------------------------------------------------------
//  子模組 4：輸出多工器
//  三個單元都同時在算，最後由它挑一個送出去
//  ★ 這是硬體和軟體最大的差別：
//    軟體 if-else 只會執行「中的」那一條；
//    硬體【三條路都在算】，只是最後選一個。多花的是面積不是時間。
// ------------------------------------------------------------
module alu_outmux #(
    parameter W = 8
) (
    input  wire [W-1:0] from_arith, from_logic, from_shift,
    input  wire [1:0]   sel,
    output reg  [W-1:0] result
);
    always @(*) begin
        case (sel)
            2'd0: result = from_arith;
            2'd1: result = from_logic;
            2'd2: result = from_shift;
            default: result = {W{1'b0}};
        endcase
    end
endmodule


// ------------------------------------------------------------
//  頂層：把四顆接起來
//
//  op[3:2] 選單元、op[1:0] 選單元內的功能
//
//                 ┌──────────┐
//    a,b ────┬───→│ alu_arith│──┐
//            ├───→│ alu_logic│──┼─→ ┌────────┐
//            └───→│ alu_shift│──┘   │ outmux │─→ y
//                 └──────────┘      └────────┘
//                                        ↑
//                                     op[3:2]
// ------------------------------------------------------------
module alu_hier #(
    parameter W = 8              // ★ 參數會往下傳給每一顆子模組
) (
    input  wire [W-1:0] a, b,
    input  wire [3:0]   op,
    output wire [W-1:0] y,
    output wire         carry,
    output wire         zero
);

    //  ---- 模組之間的連接線 ----
    //  ★ 課本 3.7.2 講的「埠對應」就是下面 .xxx(yyy) 那些
    wire [W-1:0] w_arith, w_logic, w_shift;
    wire         w_carry;

    //  三個運算單元同時工作
    alu_arith #(.W(W)) u_arith (
        .a      (a),
        .b      (b),
        .sub    (op[0]),          // op[1:0] 的最低位當加/減
        .result (w_arith),
        .carry  (w_carry)
    );

    alu_logic #(.W(W)) u_logic (
        .a      (a),
        .b      (b),
        .op     (op[1:0]),
        .result (w_logic)
    );

    alu_shift #(.W(W)) u_shift (
        .a      (a),
        .op     (op[1:0]),
        .result (w_shift)
    );

    //  最後挑一個
    alu_outmux #(.W(W)) u_mux (
        .from_arith (w_arith),
        .from_logic (w_logic),
        .from_shift (w_shift),
        .sel        (op[3:2]),
        .result     (y)
    );

    //  進位只有算術單元有意義
    assign carry = (op[3:2] == 2'd0) ? w_carry : 1'b0;
    assign zero  = ~|y;

endmodule

//  iverilog -o sim.out 01_alu_hier.v 01_alu_hier_tb.v
//  vvp sim.out
//  gtkwave 01_alu_hier.gtkw
