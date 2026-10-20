`timescale 1ns/1ps

// =====================================================================
// FreqModN_Duty50_Fix：50% duty 的修正版（講義 Do it by yourself 的一種解法）
//   和 FreqModN_Fix 同樣的道理，比較對象改成 N/2 - 1 → 每半個週期剛好 N/2 個時脈 → 週期 = N
//   ※ 只有 N 是偶數時才能剛好 50%；N 是奇數時（例如 5），只用正緣做不出 2.5 個時脈的半週期，
//     結果會是除 N-1（N = 5 → 週期 4）。真正的奇數 50% 除頻要同時用正緣和負緣
// =====================================================================
module FreqModN_Duty50_Fix (
    input            LoadModN,
    input      [3:0] Data_N,
    input            Clock_In,
    output reg       Clock_ModN_Out
);
    reg [3:0] ReadIn_Count;
    reg [2:0] Now_Count;
    reg       Is_Count;

    always @(posedge Clock_In) begin
        if (!LoadModN) begin            // 同步負準位載入
            Clock_ModN_Out <= 1'b0;     // 才剛要開始計數，所以輸出為 0
            Now_Count      <= 0;        // 目前計數到 0
            ReadIn_Count   <= Data_N;   // 讀入欲計數的次數（除頻數）
            Is_Count       <= 1'b1;     // 設定正在計數旗標為 1
        end
        else if (Is_Count) begin
            if (Now_Count == ReadIn_Count[3:1] - 1) begin   // 數到 N/2 - 1
                Clock_ModN_Out <= !Clock_ModN_Out;
                Now_Count      <= 0;
            end
            else begin
                Now_Count      <= Now_Count + 1'b1;
            end
        end
    end
endmodule
