// ============================================================
//  W3-2：★ latch 陷阱 ★  初學最常犯、最難查的錯
//  重點：組合邏輯的 always 裡，「每條路都要給值」
// ============================================================
`timescale 1ns / 1ps

module latch_trap (
    input  wire       en,
    input  wire [3:0] d,
    output reg  [3:0] bad,      // ★ 壞的寫法 → 會產生 latch
    output reg  [3:0] good      // ✅ 好的寫法
);

    // ---------- 壞的：漏了 else ----------
    //  en=0 的時候沒有指定 bad 要等於什麼，
    //  Verilog 只好幫你「記住上一次的值」→ 硬生出一個閂鎖器(latch)
    //  你以為在寫組合邏輯，實際上做出了一個會記憶的東西
    always @(*) begin
        if (en)
            bad = d;
        // 沒有 else！
    end

    // ---------- 好的：補上 else ----------
    always @(*) begin
        if (en)
            good = d;
        else
            good = 4'b0000;     // 每條路都有值 → 純組合邏輯
    end

endmodule
