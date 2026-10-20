`timescale 1ns/1ps

// =====================================================================
// SIPO_Shift_Register：4 位元串進並出（Serial In Parallel Out）左移暫存器（講義第 25、26 頁）
//   每個 Clock 正緣：先左移 1 位元，再把 SI 移入 Data_Out[0]；4 個位元同時從 Data_Out 並列輸出
// =====================================================================
module SIPO_Shift_Register (
    input            Clock,
    input            Clear,
    input            SI,
    output reg [3:0] Data_Out
);
    always @(posedge Clock) begin
        if (Clear)                              // 清除
            Data_Out <= 4'b0;                   // 清為 0
        else
            Data_Out <= {Data_Out[2:0], SI};    // 左移 1 位元，並移入新的資料（SI）至 Data_Out[0]
        // 講義寫成兩行：Data_Out = Data_Out << 1;  Data_Out[0] = SI;
        //   阻隔式 = 時，第 2 行用的是第 1 行剛算好的值，所以正確
        //   改成 <= 時用連結運算子寫成一行最清楚：{Data_Out[2:0], SI} 就是「左移再補 SI」
    end
endmodule
