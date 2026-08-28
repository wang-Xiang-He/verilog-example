// ============================================================
//  W7-1：閘延遲 —— 功能模擬看不到的東西
//  重點：真實的閘不是「瞬間」反應，每一顆都要花時間
// ============================================================
`timescale 1ns / 100ps

module gate_delay (
    input  wire a, b, c,
    output wire y_ideal,     // 理想：零延遲
    output wire y_real       // 真實：每顆閘 2ns
);

    // ---------- 理想版（功能模擬的樣子）----------
    assign y_ideal = (a & b) | c;

    // ---------- 真實版（加上閘延遲）----------
    wire n1;
    assign #2 n1     = a & b;      // AND 閘花 2ns
    assign #2 y_real = n1 | c;     // OR  閘再花 2ns  → 總共 4ns

endmodule
