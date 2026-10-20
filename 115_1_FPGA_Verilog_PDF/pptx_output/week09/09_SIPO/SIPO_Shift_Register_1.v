`timescale 1ns/1ps

// =====================================================================
// SIPO_Shift_Register_1：附錄版本，加一個 temp 暫存器（講義第 27、28 頁）
//   講義第 26 頁：「先左移再串入後並出 → 請改寫為 先並出再串進」
//   每個正緣：先把 temp 的舊值並出到 Data_Out，temp 再左移、串入 SI
//   → Data_Out 比 SIPO_Shift_Register 晚一個時脈
// =====================================================================
module SIPO_Shift_Register_1 (
    input            Clock,
    input            Clear,
    input            SI,
    output reg [3:0] Data_Out
);
    reg [3:0] temp;

    always @(posedge Clock) begin
        if (Clear) begin
            temp     <= 4'b0;                   // 講義：temp = 4'b0; //initial;
            Data_Out <= 4'b0;
        end
        else begin
            Data_Out <= temp;                   // 先並出
            temp     <= {temp[2:0], SI};        // 再左移、串入 SI 至 temp[0]
        end
    end
endmodule
