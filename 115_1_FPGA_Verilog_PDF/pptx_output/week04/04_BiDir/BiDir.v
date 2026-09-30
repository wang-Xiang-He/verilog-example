`timescale 1ns/1ps

// =====================================================================
// BiDir：雙向（inout）接腳（講義第 14、15 頁）
//   enable_in_out = 1 → 輸出模式：把 data 送到 tri_inout 接腳
//   enable_in_out = 0 → 輸入模式：放開接腳（高阻抗 z），由外部驅動
//   data_in 永遠讀取接腳上的值
// =====================================================================
module BiDir (
    input  data,
    input  enable_in_out,
    output data_in,
    inout  tri_inout            // inout 一定是 wire 類，不能宣告成 reg
);
    // 三態緩衝器：不輸出時一定要給 1'bz，才不會和外部訊號打架
    assign tri_inout = enable_in_out ? data : 1'bz;
    // 講義第 15 頁的寫法：
    //   assign tri_inout = enable_in_out ? ((data_in) ? data : tri_inout) : 1'bz;
    // 那是 SpDE 合成後的等效電路，輸出又接回自己，初學先看上面這種標準寫法即可

    assign data_in = tri_inout;
endmodule
