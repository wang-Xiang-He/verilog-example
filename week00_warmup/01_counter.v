module counter (
    input wire clk,       // 時脈訊號 (Clock)
    input wire reset,     // 重置訊號 (Reset)
    output reg [3:0] count // 4 位元的計數器輸出 (範圍從 0000 到 1111，即十進位 0 到 15)
);

    // always 區塊：當 clk 從 0 變 1 (posedge，正緣) 時觸發
    always @(posedge clk) begin
        if (reset)
            count <= 4'b0000;  // 如果重置訊號為 1，計數器歸零
        else
            count <= count + 1; // 否則計數器加 1
    end

endmodule