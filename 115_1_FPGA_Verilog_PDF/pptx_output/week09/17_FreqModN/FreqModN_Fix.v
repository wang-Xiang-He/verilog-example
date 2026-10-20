`timescale 1ns/1ps

// =====================================================================
// FreqModN_Fix：修正為真正的「除 N」（講義第 58 頁）
//   比較的對象改成 ReadIn_Count - 1：Now_Count 從 0 數到 N-1，共 N 個時脈
// =====================================================================
module FreqModN_Fix (
    input            LoadModN,
    input      [3:0] Data_N,
    input            Clock_In,
    output reg       Clock_ModN_Out
);
    reg [3:0] ReadIn_Count, Now_Count;
    reg       Is_Count;

    always @(posedge Clock_In) begin
        if (!LoadModN) begin            // 同步負準位載入
            Clock_ModN_Out <= 1'b0;     // 才剛要開始計數，所以輸出為 0
            Now_Count      <= 0;        // 目前計數到 0
            ReadIn_Count   <= Data_N;   // 讀入欲計數的次數（除頻數）
            Is_Count       <= 1'b1;     // 設定正在計數旗標為 1
        end
        else if (Is_Count) begin
            if (Now_Count == ReadIn_Count - 1) begin    // 只改這裡：- 1
                Clock_ModN_Out <= 1'b1;
                Now_Count      <= 0;
            end
            else begin
                Clock_ModN_Out <= 1'b0;
                Now_Count      <= Now_Count + 1'b1;
            end
        end
    end
endmodule
