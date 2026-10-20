`timescale 1ns/1ps

// =====================================================================
// DeMux1x4_By_DeMux1to2E：使用二個 1X2 的解多工器擴充成一個 1X4 的解多工器（講義第 52~57 頁）
//   S1 = 0：經過反向器 Not_S1 = 1 → 上面那顆動作，由 S0 決定 Y0 = D 或 Y1 = D；下面那顆 Y2 = Y3 = 0
//   S1 = 1：下面那顆動作，由 S0 決定 Y2 = D 或 Y3 = D；上面那顆 Y0 = Y1 = 0
//   ※ vlog 只要編譯本檔和 testbench，DeMux1to2E.v 會被 `include 自動帶進來
// =====================================================================
`include "DeMux1to2E.v"         // 講義寫 "DeM1to2E.V"，這裡檔名和模組名稱一致，改為 DeMux1to2E.v

module DeMux1x4_By_DeMux1to2E (
    input  S1, S0,
    input  D,
    output Y0, Y1, Y2, Y3
);
    wire Not_S1;                // 內部的接線

    assign Not_S1 = !S1;

    // 引用 2 個具有輸出致能（Enable）控制訊號的 1X2 解多工器
    //   Port Mapping - in order：DeMux1to2E (Enable, Select, D, Y0, Y1)
    DeMux1to2E My1_DeMux1to2E (Not_S1, S0, D, Y0, Y1);
    DeMux1to2E My2_DeMux1to2E (S1,     S0, D, Y2, Y3);
endmodule
