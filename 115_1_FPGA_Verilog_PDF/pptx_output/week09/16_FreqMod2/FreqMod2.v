`timescale 1ns/1ps

// =====================================================================
// FreqMod2：「除 2 器」，將輸入時脈訊號頻率除以 2 之後再輸出（講義第 53、54 頁）
//   每個 Clock_In 正緣，Clock_Mod2_Out 反相一次 → 輸出週期是輸入的 2 倍 = 頻率的一半
// =====================================================================
module FreqMod2 (
    input      Reset,
    input      Clock_In,
    output reg Clock_Mod2_Out
);
    wire Not_Clock_Mod2_Out;

    assign Not_Clock_Mod2_Out = !Clock_Mod2_Out;

    always @(posedge Reset or posedge Clock_In) begin
        if (Reset)
            Clock_Mod2_Out <= 1'b0;
        else
            Clock_Mod2_Out <= Not_Clock_Mod2_Out;
    end
    // 講義第 53 頁：「去除 assign 而令：Clock_Mod2_Out = !Clock_Mod2_Out」
    //   直接寫 Clock_Mod2_Out <= !Clock_Mod2_Out; 效果完全一樣，不需要 Not_Clock_Mod2_Out 這條線
endmodule
