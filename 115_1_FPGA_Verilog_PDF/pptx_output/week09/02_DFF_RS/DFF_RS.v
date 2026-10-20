`timescale 1ns/1ps

// =====================================================================
// DFF_RS：具有「重置」及「設定」控制訊號的正反器（講義第 3~6 頁）
//   Clock 正緣時才動作（同步）：Reset = 1 → Q = 0；否則 Set = 1 → Q = 1；否則 Q = D
//   Q_Bar 永遠是 Q 的反相（Q'）
// =====================================================================
module DFF_RS (
    input      Clock,
    input      Set,
    input      Reset,
    input      D,
    output reg Q,
    output reg Q_Bar
);
    always @(posedge Clock) begin
        if (Reset) begin            // 重置（重要功能）
            Q     <= 1'b0;
            Q_Bar <= 1'b1;
        end
        else if (Set) begin         // 設定（重要功能）
            Q     <= 1'b1;
            Q_Bar <= 1'b0;
        end
        else begin                  // 正常輸入：「D 至 Q」、Q_Bar = 「D 取 Not」
            Q     <= D;
            Q_Bar <= ~D;
        end
    end
endmodule
