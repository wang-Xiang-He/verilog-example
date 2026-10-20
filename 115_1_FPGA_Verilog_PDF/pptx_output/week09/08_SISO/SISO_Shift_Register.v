`timescale 1ns/1ps

// =====================================================================
// SISO_Shift_Register：4 位元串進串出（Serial In Serial Out），左移，移位暫存器（範例 1，講義第 19~22 頁）
//
//   SI ─► [Reg4[0]] ─► [Reg4[1]] ─► [Reg4[2]] ─► [Reg4[3]] ─► SO
//            D Q          D Q          D Q          D Q
//   每個 Clock 正緣：資料往右邊那一格移一格，SI 進入 Reg4[0]，SO 送出 Reg4[3] 的舊值
// =====================================================================
module SISO_Shift_Register (
    input      Clock,
    input      Clear,
    input      SI,
    output reg SO
);
    reg [3:0] Reg4;

    always @(posedge Clock) begin
        if (Clear)                  // Clear = 1，清除
            Reg4 <= 4'b0;           // 清為 0
        else begin
            SO      <= Reg4[3];
            Reg4[3] <= Reg4[2];
            Reg4[2] <= Reg4[1];
            Reg4[1] <= Reg4[0];
            Reg4[0] <= SI;          // 移入新的資料（SI）至 Reg4[0]
        end
    end
    // 講義第 20 頁問「順序更改，結果如何？」
    //   講義用阻隔式 =：寫的順序很重要，如果先寫 Reg4[1] = Reg4[0] 再寫 Reg4[2] = Reg4[1]，
    //   同一個時脈內 Reg4[0] 會一路被複製下去，就不是一次移一格了
    //   這裡用非阻隔式 <=：右邊全部用「舊值」，5 行的順序怎麼排結果都一樣（說明檔有實際模擬對照）
endmodule
