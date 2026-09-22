`timescale 1ns/1ps

// =====================================================================
// dff：D 型正反器（D Flip-Flop）
//   時脈正緣時，把 din 存入 q；其餘時間 q 保持不變
// =====================================================================
module dff (din, clk, q);
    input  din, clk;
    output q;
    reg    q;

    always @(posedge clk)
        q <= din;      // 講義寫 q = din；正反器建議用非阻隔式 <=（見 03_Hierar 的說明）
endmodule
