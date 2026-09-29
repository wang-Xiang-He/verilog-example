`timescale 1ns/1ps

// =====================================================================
// Register8：8 位元暫存器（在時脈正緣存入 data）
// =====================================================================
module Register8 (
    input            Clock,
    input            Reset,
    input      [7:0] data,
    output reg [7:0] q              // 在 always 裡被賦值 → 必須是 reg，直接寫在埠宣告裡
);
    always @(posedge Clock) begin   // posedge = 正緣（時脈由 0 變 1 的瞬間）
        if (Reset)
            q <= 8'b0;              // 同步重置
        else
            q <= data;
    end
    // ※ 講義寫 q = data（阻隔式賦值 blocking），這裡改成 q <= data（非阻隔式 non-blocking）。
    //   原因：Register8 的 q 直接接到 Rotate_Data，兩個都在同一個時脈正緣更新；
    //   用 = 時，哪一個先執行由模擬器決定（競爭條件 race condition），
    //   結果可能差一個時脈。正反器 / 暫存器一律用 <= 是業界通則。
endmodule
