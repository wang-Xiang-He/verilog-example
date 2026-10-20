`timescale 1ns/1ps

// =====================================================================
// Mux2to1E：具有輸出致能（Enable）控制訊號的 2 對 1 多工器（講義第 42 頁）
//   Enable = 1：Select = 0 → Y = I0、Select = 1 → Y = I1
//   Enable = 0：Y = 0
//   這個檔案會被 Mux4x1_By_Mux2to1E.v 用 `include 引入，vlog 的檔案清單【不要】再列它
// =====================================================================
module Mux2to1E (
    input      Enable,
    input      Select,
    input      I0,
    input      I1,
    output reg Y
);
    always @(*) begin           // 講義：always @(Enable or Select or I0 or I1)
        if (Enable == 1'b1) begin       // 輸出致能
            case (Select)
                1'b0:    Y = I0;
                1'b1:    Y = I1;
                default: Y = 1'bx;      // 不確定值，Unknown
            endcase
        end
        else begin
            Y = 1'b0;   // 講義寫 Y = 1'bx;，並註明「有誤？修正為 0 即可」
                        //   不致能的那一顆如果輸出 x，經過後面的 OR：x | 1 = 1，但 x | 0 = x（講義第 43 頁）
        end
    end
endmodule
