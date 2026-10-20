`timescale 1ns/1ps

// =====================================================================
// RAS_NRPC：具「非同步負準位重置」與「時脈正緣觸發」的 4 位元暫存器（講義第 15、16 頁）
//   Reset = 0 → 立刻清除為 0；否則 Clock 正緣時 Reg_Out1 = Reg_In
// =====================================================================
module RAS_NRPC (
    input            Reset,
    input            Clock,
    input      [3:0] Reg_In,
    output reg [3:0] Reg_Out1
);
    always @(negedge Reset or posedge Clock) begin  // 非同步負緣重置
        if (!Reset)                 // Reset = 0
            Reg_Out1 <= 4'd0;       // 清除為 0
        else                        // Reset = 1 且 Clock = posedge
            Reg_Out1 <= Reg_In;     // 將 Reg_In 傳入 Reg_Out1
    end
endmodule
