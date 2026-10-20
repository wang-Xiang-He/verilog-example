`timescale 1ns/1ps

// =====================================================================
// Latch_RS_tb：閂鎖測試平台
//   講義第 2 頁：「Enable 輸入埠不見了，自行模擬」——講義的波形用 Clock 當 Enable，這裡自己寫
//   重點：Enable = 1 時 Q 跟著 D 走（不等時脈邊緣）；Enable = 0 時 Q 保持
// =====================================================================
module Latch_RS_tb;
    reg  Enable, Set, Reset, D;
    wire Q;

    Latch_RS uut (.Enable(Enable), .Set(Set), .Reset(Reset), .D(D), .Q(Q));

    initial begin
        $monitor("t=%0d  Reset=%b Set=%b Enable=%b D=%b  ->  Q=%b", $time, Reset, Set, Enable, D, Q);
            Reset = 0; Set = 0; Enable = 0; D = 0;   // 一開始什麼都沒做 → Q 不確定
        #10 Reset = 1;                              // 重置 → Q = 0
        #10 Reset = 0; Set = 1;                     // 設定 → Q = 1
        #10 Set = 1;   D = 0; Enable = 1;           // Set 優先於 Enable → Q 還是 1
        #10 Set = 0;                                // 換成 Enable 控制 → Q = D = 0
        #5  D = 1;                                  // Enable = 1：D 一變 Q 立刻變（透明）
        #5  D = 0;
        #5  D = 1;
        #5  Enable = 0;                             // 關掉 Enable → Q 保持 1
        #5  D = 0;                                  // D 再怎麼變，Q 都不動
        #5  D = 1;
        #5  D = 0;
        #5  Reset = 1; Set = 1; Enable = 1;         // 三個都是 1：Reset 優先
        #10 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Reset=0 Set=0 Enable=0 D=0  ->  Q=x
//   t=10  Reset=1 Set=0 Enable=0 D=0  ->  Q=0
//   t=20  Reset=0 Set=1 Enable=0 D=0  ->  Q=1
//   t=30  Reset=0 Set=1 Enable=1 D=0  ->  Q=1
//   t=40  Reset=0 Set=0 Enable=1 D=0  ->  Q=0
//   t=45  Reset=0 Set=0 Enable=1 D=1  ->  Q=1
//   t=50  Reset=0 Set=0 Enable=1 D=0  ->  Q=0
//   t=55  Reset=0 Set=0 Enable=1 D=1  ->  Q=1
//   t=60  Reset=0 Set=0 Enable=0 D=1  ->  Q=1
//   t=65  Reset=0 Set=0 Enable=0 D=0  ->  Q=1
//   t=70  Reset=0 Set=0 Enable=0 D=1  ->  Q=1
//   t=75  Reset=0 Set=0 Enable=0 D=0  ->  Q=1
//   t=80  Reset=1 Set=1 Enable=1 D=0  ->  Q=0
//   ** Note: $stop    : Latch_RS_tb.v(29)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Latch_RS_tb at Latch_RS_tb.v line 29
//
// 觀察重點：Enable=1 的期間（t=40~60）Q 跟著 D 一起變，不必等時脈邊緣（準位觸發）；Enable=0 後（t=60 起）Q 停在 1，D 怎麼變都不動；優先權 Reset > Set > Enable


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Latch_RS.v Latch_RS_tb.v            Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Latch_RS_tb     Simulate > Start Simulation → work → Latch_RS_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Latch_RS_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Latch_RS.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Latch_RS_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
