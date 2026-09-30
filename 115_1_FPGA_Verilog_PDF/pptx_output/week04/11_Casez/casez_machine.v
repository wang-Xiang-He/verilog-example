`timescale 1ns/1ps

// =====================================================================
// casez_machine：casez 範例（講義第 34~36 頁）
//   每個時脈正緣依 Condition 的最低位元決定 Out
//   casez 項目中的 z（或 ?）代表「這個位元不在乎」
//     Condition[0] = 0 → Out = 000
//     Condition[0] = 1 → Out = 001
//     其他（Condition[0] 是 x 或 z）→ Out = 111
// =====================================================================
module casez_machine (
    input            Clock,
    input      [1:0] Condition,
    output reg [2:0] Out
);
    always @(posedge Clock) begin
        casez (Condition)
            2'bz0   : Out <= 3'b000;   // 講義用 =；在時脈邊緣更新建議用 <=
            2'bz1   : Out <= 3'b001;
            default : Out <= 3'b111;
        endcase
        // 2'bz0 也可以寫成 2'b?0，意思完全相同，而且比較不會和「高阻抗」搞混
    end
endmodule
