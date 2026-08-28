// ============================================================
//  W3-4：★★ 本週最重要 ★★  阻塞 = 與非阻塞 <= 的差別
//  重點：一模一樣的三行程式碼，只換符號，做出完全不同的電路
// ============================================================
`timescale 1ns / 1ps

module blocking_vs_non (
    input  wire clk,
    input  wire rst,
    input  wire d,
    // 非阻塞版（正確的移位暫存器）
    output reg  q1_nb, q2_nb, q3_nb,
    // 阻塞版（會塌掉）
    output reg  q1_b,  q2_b,  q3_b
);

    // ---------------- 非阻塞 <= ----------------
    //  「先全部把右邊讀好，再一起寫進左邊」
    //  所以 q2 讀到的是 q1 的「舊值」→ 資料一級一級往後傳
    //
    //     d ──[FF]──[FF]──[FF]── q3      三顆正反器串起來
    //
    always @(posedge clk) begin
        if (rst) begin
            q1_nb <= 0; q2_nb <= 0; q3_nb <= 0;
        end else begin
            q1_nb <= d;
            q2_nb <= q1_nb;      // 讀到的是「上一拍」的 q1
            q3_nb <= q2_nb;
        end
    end

    // ---------------- 阻塞 = ----------------
    //  「一行做完才做下一行」，跟寫軟體一樣
    //  所以 q2 讀到的是 q1 剛剛被寫入的「新值」→ 三個同時等於 d
    //
    //     d ──[FF]── q1 = q2 = q3         只剩一顆正反器！
    //
    always @(posedge clk) begin
        if (rst) begin
            q1_b = 0; q2_b = 0; q3_b = 0;
        end else begin
            q1_b = d;
            q2_b = q1_b;         // 讀到的是「這一拍剛寫入」的 q1
            q3_b = q2_b;
        end
    end

endmodule
