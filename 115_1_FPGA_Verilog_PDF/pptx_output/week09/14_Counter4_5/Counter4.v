`timescale 1ns/1ps

// =====================================================================
// Counter4：10 位元正緣觸發上數計數器，旗標寫在 always 區塊「內」（講義第 46~48 頁）
//   若計數值為 0，則 Zero = 1
//   若計數值為 1023，則 Max_1023 = 1
//   若計數值為偶同位（1 的個數為偶數），則 Even = 1
//   若計數值為奇同位（1 的個數為奇數），則 Odd = 1
// =====================================================================
module Counter4 (
    input            Clock,
    input            Reset,
    output reg       Zero,
    output reg       Max_1023,
    output reg       Even,
    output reg       Odd,
    output reg [9:0] Out
);
    // 講義第 46 頁：「將 Reg 修正為 wire 結果如何？」
    //   Zero 等 4 個旗標在 always 裡被賦值，一定要是 reg；改成 wire 會編譯錯誤（說明檔有實際錯誤訊息）
    always @(posedge Clock or posedge Reset) begin
        if (Reset)                      // 重置
            Out <= 10'd0;               // 清除為 0
        else
            Out <= Out + 1'b1;          // 計數值加 1

        Zero     <= !(|Out);            // 縮減 OR 再取反：全部是 0 → 1
        Max_1023 <= &Out;               // 縮減 AND：全部是 1 → 1
        Odd      <= ^Out;               // 縮減 XOR：1 的個數為奇數 → 1
        Even     <= !(^Out);
    end
    // ※ 講義用阻隔式 =，旗標用的是「剛加 1 之後」的 Out
    //   改成非阻隔式 <= 之後，旗標用的是「加 1 之前」的 Out → 旗標會晚一個時脈（模擬結果可以看到）
    //   這也是講義第 49 頁說「將判斷計數值的寫法置於 always 區塊外效能較佳」的原因之一 → 見 Counter5
endmodule
