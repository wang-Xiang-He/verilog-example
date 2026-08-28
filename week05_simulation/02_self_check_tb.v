// ============================================================
//  W5-2：★ 自我檢查測試平台的標準寫法 ★
//  重點：測試自己算答案、自己比對、自己報分數
//        你不用用眼睛看幾百行輸出
// ============================================================
`timescale 1ns / 1ps

module alu4_tb;

    reg  [3:0] a, b;
    reg  [2:0] op;
    wire [4:0] y;
    wire       zero;

    integer pass = 0, fail = 0;
    integer i, j, k;
    reg [4:0] golden;          // 「標準答案」

    alu4 uut (.a(a), .b(b), .op(op), .y(y), .zero(zero));

    // ---------- 參考模型：獨立算一次正確答案 ----------
    function [4:0] ref_model;
        input [3:0] x, z;
        input [2:0] o;
        begin
            case (o)
                3'd0: ref_model = x + z;
                3'd1: ref_model = x - z;
                3'd2: ref_model = x & z;
                3'd3: ref_model = x | z;
                3'd4: ref_model = x ^ z;
                3'd5: ref_model = ~x;
                3'd6: ref_model = x << 1;
                3'd7: ref_model = x >> 1;
                default: ref_model = 5'bx;
            endcase
        end
    endfunction

    // ---------- 一次檢查 ----------
    task check;
        begin
            #5;
            golden = ref_model(a, b, op);
            if (y === golden) begin
                pass = pass + 1;
            end else begin
                fail = fail + 1;
                $display("   [X] op=%0d a=%0d b=%0d → 得到 %0d，應該是 %0d",
                         op, a, b, y, golden);
            end
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, alu4_tb);

        $display("");
        $display("  ===== 窮舉測試：8 種運算 x 16 x 16 = 2048 組 =====");

        for (k = 0; k < 8; k = k + 1)
            for (i = 0; i < 16; i = i + 1)
                for (j = 0; j < 16; j = j + 1) begin
                    op = k[2:0]; a = i[3:0]; b = j[3:0];
                    check;
                end

        $display("");
        $display("  ===== 亂數測試：500 組 =====");
        for (i = 0; i < 500; i = i + 1) begin
            a = $random; b = $random; op = $random;
            check;
        end

        $display("");
        $display("  ==========================================");
        $display("     通過 %0d 組，失敗 %0d 組", pass, fail);
        if (fail == 0) $display("     >>> 全部通過 ✓");
        else           $display("     >>> 有錯誤 ✗");
        $display("  ==========================================");
        $display("");
        $display("  ★ 這就是「自我檢查測試平台」：");
        $display("    1. 寫一個獨立的參考模型算標準答案");
        $display("    2. 每組輸入都比對 DUT 和參考模型");
        $display("    3. 最後報總分 —— 你只要看最後一行");
        $display("");
        $display("  ★ 為什麼用 === 不用 == ？");
        $display("    == 遇到 x 會回傳 x（不確定），=== 會嚴格比較連 x 都要一樣");
        $display("    測試平台一律用 === 和 !==");
        $display("");

        $finish;
    end
endmodule
