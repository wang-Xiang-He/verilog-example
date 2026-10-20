`timescale 1ns/1ps

// =====================================================================
// Counter5：10 位元正緣觸發上數計數器，旗標寫在 always 區塊「外」（講義第 49、50 頁）
//   ※ 講義第 49 頁的模組名稱還是寫 Counter4，和上一個同名，這裡改為 Counter5
//   將判斷計數值的寫法，置於 always 區塊外「效能」較佳：旗標是純組合邏輯，永遠和 Out 同步
// =====================================================================
module Counter5 (
    input            Clock,
    input            Reset,
    output           Zero,
    output           Max_1023,
    output           Even,
    output           Odd,
    output reg [9:0] Out
);
    assign Zero     = !(|Out);          // 不寫在 always block 內
    assign Max_1023 = &Out;
    assign Odd      = ^Out;
    assign Even     = !(Odd);           // 或寫成 Even = ~^Out

    always @(posedge Clock or posedge Reset) begin
        if (Reset)                      // 重置
            Out <= 10'd0;               // 清除為 0
        else
            Out <= Out + 1'b1;          // 計數值 加 1
    end
endmodule
