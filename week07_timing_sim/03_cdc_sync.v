// ============================================================
//  W7-3：跨時脈域 CDC 與雙 FF 同步器
//  重點：訊號從一個時脈域進到另一個，一定要先同步
// ============================================================
`timescale 1ns / 100ps

module cdc_sync (
    input  wire clk_dst,
    input  wire rst,
    input  wire async_in,      // 來自另一個時脈域（或外部按鈕）
    output reg  unsafe_out,    // ★ 危險：直接用
    output reg  safe_out,      // ✅ 安全：經過雙 FF 同步器
    output reg  sync_ff1       // 中間級（拉出來給波形看）
);

    // ---------- 危險寫法：直接取樣 ----------
    //  如果 async_in 剛好在時脈邊緣附近變化，
    //  正反器可能進入「亞穩態」—— 輸出既不是 0 也不是 1，
    //  要花不定的時間才穩定下來，甚至傳染給下游。
    always @(posedge clk_dst) begin
        if (rst) unsafe_out <= 1'b0;
        else     unsafe_out <= async_in;
    end

    // ---------- 安全寫法：雙 FF 同步器 ----------
    //  第一顆可能亞穩態，但給它一整個時脈週期穩定下來，
    //  第二顆取到的就是乾淨的 0 或 1。
    //
    //   async_in ──[FF1]──[FF2]── safe_out
    //
    always @(posedge clk_dst) begin
        if (rst) begin
            sync_ff1 <= 1'b0;
            safe_out <= 1'b0;
        end else begin
            sync_ff1 <= async_in;
            safe_out <= sync_ff1;
        end
    end

endmodule
