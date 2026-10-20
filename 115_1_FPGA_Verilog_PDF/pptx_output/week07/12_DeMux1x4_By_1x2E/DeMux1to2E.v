`timescale 1ns/1ps

// =====================================================================
// DeMux1to2E：具有輸出致能（Enable）控制訊號的 1X2 解多工器（講義第 54~56 頁）
//   Enable = 1：Select = 0 → Y0 = D、Select = 1 → Y1 = D
//   Enable = 0：Y0 = Y1 = 0（不致能）
//   這個檔案會被 DeMux1x4_By_DeMux1to2E.v 用 `include 引入，vlog 的檔案清單【不要】再列它
// =====================================================================
module DeMux1to2E (
    input      Enable,
    input      Select,
    input      D,
    output reg Y0,
    output reg Y1
);
    always @(*) begin           // 講義：always @(Enable or Select or D)
        if (Enable == 1'b1) begin           // 輸出致能
            if (Select == 1'b0) begin       // 輸出到 Y0
                Y0 = D;
                Y1 = 0;
            end
            else if (Select == 1'b1) begin  // 輸出到 Y1
                Y0 = 0;
                Y1 = D;
            end
            else begin
                Y0 = 1'b0;                  // 輸出為 0
                Y1 = 1'b0;
            end
        end
        else begin                          // Enable == 1'b0，不致能
            Y0 = 1'b0;                      // 輸出為 0
            Y1 = 1'b0;
        end
    end
endmodule
