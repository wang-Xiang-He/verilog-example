`timescale 1ns/1ps

// =====================================================================
// RS_NRPC：「同步正準位重置」與「時脈正緣觸發」訊號控制的 4 位元暫存器（講義第 17、18 頁）
//   ※ 講義標題寫「正準位重置」，但程式是 if (!Reset) → Reset = 0 時清除，實際上是「負準位」
//   在 posedge Clock 時才執行 begin ... end 內的敘述
// =====================================================================
module RS_NRPC (
    input            Reset,
    input            Clock,
    input      [3:0] Reg_In,
    output reg [3:0] Reg_Out3
);
    always @(posedge Clock) begin
        if (!Reset)                 // Reset = 0
            Reg_Out3 <= 4'd0;       // 清除為 0
        else
            Reg_Out3 <= Reg_In;     // 將 Reg_In 傳入 Reg_Out3
    end
endmodule
