`timescale 1ns/1ps

// =====================================================================
// Forever_While_tb：while 與 forever 迴圈（講義第 46 頁）
//   範例：產生週期 40 個時間單位的時脈，並在第 500 個時間單位停止
//   只有 testbench；forever / while 多用在測試平台，不用在要合成的電路
// =====================================================================
module Forever_While_tb;
    parameter duty_cycle = 20;          // 半週期 20 → 週期 40
    parameter end_time   = 500;

    reg     clock;
    integer n_pos, count;

    // ---------- forever：無限重複，要靠 disable 把它停下來 ----------
    initial begin : clock_seqence       // 講義的拼字（sequence 少了 u），保持原樣
        clock = 0;
        forever
            #duty_cycle clock = ~clock;
    end

    initial
        #end_time disable clock_seqence;   // t=500 時停止產生時脈

    // 數一下總共有幾個正緣
    initial n_pos = 0;
    always @(posedge clock) begin
        n_pos = n_pos + 1;
        $display("t=%0d  posedge #%0d", $time, n_pos);
    end

    // ---------- while：條件成立就重複 ----------
    initial begin
        count = 3;
        while (count > 0) begin
            $display("t=%0d  while loop: count = %0d", $time, count);
            count = count - 1;
        end
        $display("t=%0d  while loop done, count = %0d", $time, count);
    end

    initial begin
        #(end_time + 50);               // 時脈停止後再等 50，確認 clock 沒有再變化
        $display("t=%0d  clock = %b (stopped at t=%0d)", $time, clock, end_time);
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  while loop: count = 3
//   t=0  while loop: count = 2
//   t=0  while loop: count = 1
//   t=0  while loop done, count = 0
//   t=20  posedge #1
//   t=60  posedge #2
//   t=100  posedge #3
//   t=140  posedge #4
//   t=180  posedge #5
//   t=220  posedge #6
//   t=260  posedge #7
//   t=300  posedge #8
//   t=340  posedge #9
//   t=380  posedge #10
//   t=420  posedge #11
//   t=460  posedge #12
//   t=550  clock = 0 (stopped at t=500)
//   ** Note: $stop    : Forever_While_tb.v(45)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Forever_While_tb at Forever_While_tb.v line 45
//
// 觀察重點：while 在 t=0 就跑完 3 圈（迴圈本身不花時間）；時脈週期 40，正緣在 20, 60, ... 460 共 12 個，t=500 被 disable 後不再變化


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Forever_While_tb.v                  Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Forever_While_tb Simulate > Start Simulation → work → Forever_While_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Forever_While_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 留空（本範例只有 testbench）
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Forever_While_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
