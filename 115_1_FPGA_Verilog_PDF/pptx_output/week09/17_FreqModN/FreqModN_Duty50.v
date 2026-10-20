`timescale 1ns/1ps

// =====================================================================
// FreqModN_Duty50：讓輸出的工作週期（Duty cycle）= 50%（講義第 59、60 頁，照講義的寫法）
//   每次 Now_Count 數到 N/2（ReadIn_Count[3:1]）時把輸出反相
//   ※ Now_Count 從 0 數到 N/2，每半個週期是 N/2 + 1 個時脈 → 週期 = 2 × (N/2 + 1)，不是 N
//     N = 5 → 週期 6；N = 6 → 週期 8（講義第 60 頁 N = 5 的波形確實是 6 個時脈）
// =====================================================================
module FreqModN_Duty50 (
    input            LoadModN,
    input      [3:0] Data_N,
    input            Clock_In,
    output reg       Clock_ModN_Out
);
    reg [3:0] ReadIn_Count;
    reg [2:0] Now_Count;                // 講義：reg [2:0] Now_Count;
    reg       Is_Count;

    always @(posedge Clock_In) begin
        if (!LoadModN) begin            // 同步負準位載入
            Clock_ModN_Out <= 1'b0;     // 才剛要開始計數，所以輸出為 0
            Now_Count      <= 0;        // 目前計數到 0
            ReadIn_Count   <= Data_N;   // 讀入欲計數的次數（除頻數）
            Is_Count       <= 1'b1;     // 設定正在計數旗標為 1
        end
        else if (Is_Count) begin
            if (Now_Count == ReadIn_Count[3:1]) begin   // 數到 N/2
                Clock_ModN_Out <= !Clock_ModN_Out;      // 輸出反相
                Now_Count      <= 0;
            end
            else begin
                Clock_ModN_Out <= Clock_ModN_Out;       // 保持
                Now_Count      <= Now_Count + 1'b1;
            end
        end
    end
endmodule
