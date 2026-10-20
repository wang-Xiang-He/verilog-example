`timescale 1ns/1ps

// =====================================================================
// DFF_pr_tb：DFF_pr 測試平台（講義第 12 頁，講義的模組名稱是 DFF_pr_vlg_tst）
//   講義：`timescale 1ps/1ps、CLK 每 #1 反相、D 每 #10 換一次 → 一組 D 有 5 個時脈，輸出太長
//   這裡：CLK 每 #5 反相（週期 10ns、正緣在 10, 20, 30 ...），D 在負緣（15, 35 ...）換值
// =====================================================================
module DFF_pr_tb;
    reg  CLK, D;
    wire Q;

    DFF_pr i1 (Q, D, CLK);              // UDP 只能依順序連接（call by order）

    initial CLK = 1'b1;                 // 講義：initial CLK = 1'b1;
    always #5 CLK = ~CLK;

    initial begin
        $monitor("t=%0d  CLK=%b D=%b  ->  Q=%b", $time, CLK, D, Q);
            D = 1'b0;
        #15 D = 1'b1;                   // 15、25 ... 剛好在 CLK = 0 的中間改變 D
        #20 D = 1'b0;
        #20 D = 1'b0;
        #20 D = 1'b1;
        #20 D = 1'b0;
        #20 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  CLK=1 D=0  ->  Q=x
//   t=5  CLK=0 D=0  ->  Q=x
//   t=10  CLK=1 D=0  ->  Q=0
//   t=15  CLK=0 D=1  ->  Q=0
//   t=20  CLK=1 D=1  ->  Q=1
//   t=25  CLK=0 D=1  ->  Q=1
//   t=30  CLK=1 D=1  ->  Q=1
//   t=35  CLK=0 D=0  ->  Q=1
//   t=40  CLK=1 D=0  ->  Q=0
//   t=45  CLK=0 D=0  ->  Q=0
//   t=50  CLK=1 D=0  ->  Q=0
//   t=55  CLK=0 D=0  ->  Q=0
//   t=60  CLK=1 D=0  ->  Q=0
//   t=65  CLK=0 D=0  ->  Q=0
//   t=70  CLK=1 D=0  ->  Q=0
//   t=75  CLK=0 D=1  ->  Q=0
//   t=80  CLK=1 D=1  ->  Q=1
//   t=85  CLK=0 D=1  ->  Q=1
//   t=90  CLK=1 D=1  ->  Q=1
//   t=95  CLK=0 D=0  ->  Q=1
//   t=100  CLK=1 D=0  ->  Q=0
//   t=105  CLK=0 D=0  ->  Q=0
//   t=110  CLK=1 D=0  ->  Q=0
//   ** Note: $stop    : DFF_pr_tb.v(25)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module DFF_pr_tb at DFF_pr_tb.v line 25
//
// 觀察重點：Q 只在 CLK 由 0 變 1（t=10、20 ...）時才跟著 D 變；D 在 CLK=0 的中間改變（t=15、35 ...）時 Q 不動；t=0 的 Q=x 是因為還沒遇到第一個正緣


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog DFF_pr.v DFF_pr_tb.v                Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.DFF_pr_tb       Simulate > Start Simulation → work → DFF_pr_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 DFF_pr_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 DFF_pr.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, DFF_pr_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
