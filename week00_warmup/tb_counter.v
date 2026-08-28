module tb_counter;

    // 定義要送給計數器的輸入訊號 (用 reg，因為我們要在程序中改變它)
    reg clk;
    reg reset;

    // 接收計數器輸出的訊號 (用 wire，像接線一樣)
    wire [3:0] count;

    // 把剛剛寫好的 counter 叫出來用 (實例化)，命名為 uut (Unit Under Test)
    // .clk(clk) 的意思是：把計數器的 clk 腳位，接到測試平台的 clk 訊號上
    counter uut (
        .clk(clk),
        .reset(reset),
        .count(count)
    );

    // 產生時脈訊號 (每 5 個時間單位反轉一次，所以週期是 10)
    always #5 clk = ~clk;

    // initial 區塊：模擬開始時會從頭到尾執行一次
    initial begin
        // ★這兩行非常重要！要加這兩行才能產生波形檔給 GTKWave 看★
        $dumpfile("wave.vcd");    // 指定波形檔名
        $dumpvars(0, tb_counter); // 記錄這個模組下的所有訊號

        // 初始狀態
        clk = 0;
        reset = 1;     // 先按著重置按鈕

        #15 reset = 0; // 經過 15 個時間單位後，放開重置按鈕

        #100;          // 讓模擬器繼續跑 100 個時間單位，觀察計數器運作

        $finish;       // 結束模擬
    end

    // (選用) 在終端機印出文字訊息，方便除錯
    initial begin
        $monitor("時間=%0t | 重置=%b | 計數值=%b (%d)", $time, reset, count, count);
    end

endmodule