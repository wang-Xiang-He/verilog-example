`timescale 1ns/1ps

// =====================================================================
// FreqModN：「除 N 器」，可程式的除頻器（將輸入時脈除以 N 後輸出）（講義第 55~57 頁，原版）
//   LoadModN = 0 時讀入 Data_N（同步負準位載入），之後開始計數
//   每次 Now_Count 數到 ReadIn_Count 時輸出 1 個時脈寬的 1
//   ※ Now_Count 從 0 數到 N 共 N + 1 個時脈 → 實際上是「除 N+1」（講義第 57 頁：「÷6 ⇒ Not ÷5」）
// =====================================================================
module FreqModN (
    input            LoadModN,
    input      [3:0] Data_N,
    input            Clock_In,
    output reg       Clock_ModN_Out
);
    reg [3:0] ReadIn_Count, Now_Count;
    reg       Is_Count;

    always @(posedge Clock_In) begin    // 正緣脈波訊號
        if (!LoadModN) begin            // 同步負準位載入
            Clock_ModN_Out <= 1'b0;     // 才剛要開始計數，所以輸出為 0
            Now_Count      <= 0;        // 目前計數到 0
            ReadIn_Count   <= Data_N;   // 讀入欲計數的次數（除頻數）
            Is_Count       <= 1'b1;     // 設定正在計數旗標為 1
        end
        else if (Is_Count) begin        // 正在計數
            if (Now_Count == ReadIn_Count) begin    // 如果目前計數的值 = 除頻數
                Clock_ModN_Out <= 1'b1;             // 已到除頻值，所以輸出為 1
                Now_Count      <= 0;                // 新設定目前計數值為 0
            end
            else begin
                Clock_ModN_Out <= 1'b0;             // 尚未計數到除頻數，所以輸出為 0
                Now_Count      <= Now_Count + 1'b1; // 目前的計數值 +1
            end
        end
    end
endmodule
