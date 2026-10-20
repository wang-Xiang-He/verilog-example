`timescale 1ns/1ps

// =====================================================================
// JKF_pr_tb：JKF_pr 測試平台（講義第 9 頁，講義的模組名稱是 JKF_pr_vlg_tst）
//   測試順序和講義相同：RST=1 → JK=10 → JK=01 → JK=11 → RST=1 → JK=00
//   講義每組維持 #10 = 5 個時脈；這裡 CLK 週期 10ns、每組維持 20ns = 2 個時脈
// =====================================================================
module JKF_pr_tb;
    reg  CLK, J, K, RST;
    wire Q;

    JKF_pr i1 (Q, J, K, CLK, RST);      // call by order

    initial CLK = 1'b1;
    always #5 CLK = ~CLK;               // CLK=1：0~5、10~15、20~25 ...

    initial begin
        $monitor("t=%0d  CLK=%b RST=%b J=%b K=%b  ->  Q=%b", $time, CLK, RST, J, K, Q);
            RST = 1'b1; J = 1'b0; K = 1'b0;     // 重置 → Q = 0
        #20 RST = 1'b0; J = 1'b1; K = 1'b0;     // 設定 → Q = 1
        #20             J = 1'b0; K = 1'b1;     // 清除 → Q = 0
        #20             J = 1'b1; K = 1'b1;     // 反相 → 每次 CLK = 1 時 Q 反一次
        #20 RST = 1'b1; J = 1'b0;               // 重置 → Q = 0
        #20 RST = 1'b0; J = 1'b0; K = 1'b0;     // 不變
        #20 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  CLK=1 RST=1 J=0 K=0  ->  Q=0
//   t=5  CLK=0 RST=1 J=0 K=0  ->  Q=0
//   t=10  CLK=1 RST=1 J=0 K=0  ->  Q=0
//   t=15  CLK=0 RST=1 J=0 K=0  ->  Q=0
//   t=20  CLK=1 RST=0 J=1 K=0  ->  Q=1
//   t=25  CLK=0 RST=0 J=1 K=0  ->  Q=1
//   t=30  CLK=1 RST=0 J=1 K=0  ->  Q=1
//   t=35  CLK=0 RST=0 J=1 K=0  ->  Q=1
//   t=40  CLK=1 RST=0 J=0 K=1  ->  Q=0
//   t=45  CLK=0 RST=0 J=0 K=1  ->  Q=0
//   t=50  CLK=1 RST=0 J=0 K=1  ->  Q=0
//   t=55  CLK=0 RST=0 J=0 K=1  ->  Q=0
//   t=60  CLK=1 RST=0 J=1 K=1  ->  Q=1
//   t=65  CLK=0 RST=0 J=1 K=1  ->  Q=1
//   t=70  CLK=1 RST=0 J=1 K=1  ->  Q=0
//   t=75  CLK=0 RST=0 J=1 K=1  ->  Q=0
//   t=80  CLK=1 RST=1 J=0 K=1  ->  Q=0
//   t=85  CLK=0 RST=1 J=0 K=1  ->  Q=0
//   t=90  CLK=1 RST=1 J=0 K=1  ->  Q=0
//   t=95  CLK=0 RST=1 J=0 K=1  ->  Q=0
//   t=100  CLK=1 RST=0 J=0 K=0  ->  Q=0
//   t=105  CLK=0 RST=0 J=0 K=0  ->  Q=0
//   t=110  CLK=1 RST=0 J=0 K=0  ->  Q=0
//   t=115  CLK=0 RST=0 J=0 K=0  ->  Q=0
//   ** Note: $stop    : JKF_pr_tb.v(25)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module JKF_pr_tb at JKF_pr_tb.v line 25
//
// 觀察重點：和講義第 10 頁相同：RST=1 → Q=0；JK=10 → Q=1；JK=01 → Q=0；JK=11 → 每次 CLK 變成 1 時 Q 反相一次（t=60、70）；JK=00 → 保持


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog JKF_pr.v JKF_pr_tb.v                Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.JKF_pr_tb       Simulate > Start Simulation → work → JKF_pr_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 JKF_pr_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 JKF_pr.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, JKF_pr_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
