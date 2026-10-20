`timescale 1ns/1ps

// =====================================================================
// Enable_FF1_tb：Enable_FF1 測試平台
//   u1   ：Enable、Condition、D 各種組合（講義第 8 頁：先 Enable = 0 → Q = x，之後 Q = D、Q = Q）
//   u_div：講義第 8 頁「如何修正 Testbench 以顯示除 2 功能？」
//          這顆沒有 Q_Bar，所以在 testbench 用 ~Qd 接回 D；但 Q 一開始是 x，~x 還是 x，永遠除不起來
//          → 第一個時脈先用 init = 1 讓 D = 0，給 Qd 一個初值，之後才接 ~Qd
// =====================================================================
module Enable_FF1_tb;
    reg  Clock, Condition, Enable, D, init;
    wire Q, Qd;
    wire Dd = init ? 1'b0 : ~Qd;

    initial Clock = 1'b0;
    always #5 Clock = ~Clock;           // 週期 10ns，正緣在 5、15、25 ...

    Enable_FF1 u1    (.Clock(Clock), .Condition(Condition), .Enable(Enable), .D(D),  .Q(Q));
    Enable_FF1 u_div (.Clock(Clock), .Condition(1'b0),      .Enable(1'b1),   .D(Dd), .Q(Qd));

    initial begin
        $monitor("t=%0d  Clock=%b Enable=%b Condition=%b D=%b  ->  Q=%b   |  div2: Qd=%b",
                 $time, Clock, Enable, Condition, D, Q, Qd);
            init = 1; Enable = 0; Condition = 0; D = 1;   // Enable = 0 → Q = x
        #10 init = 0; Enable = 1;                         // Condition = 0 → Q = D
        #10 D = 0;
        #10 D = 1;
        #10 Condition = 1;  D = 0;                        // Condition = 1 → Q 保持（不理 D）
        #20 D = 1;
        #10 Condition = 0;                                // 又開始跟著 D
        #10 Enable = 0;                                   // 不致能 → Q = x
        #10 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Clock=0 Enable=0 Condition=0 D=1  ->  Q=x   |  div2: Qd=x
//   t=5  Clock=1 Enable=0 Condition=0 D=1  ->  Q=x   |  div2: Qd=0
//   t=10  Clock=0 Enable=1 Condition=0 D=1  ->  Q=x   |  div2: Qd=0
//   t=15  Clock=1 Enable=1 Condition=0 D=1  ->  Q=1   |  div2: Qd=1
//   t=20  Clock=0 Enable=1 Condition=0 D=0  ->  Q=1   |  div2: Qd=1
//   t=25  Clock=1 Enable=1 Condition=0 D=0  ->  Q=0   |  div2: Qd=0
//   t=30  Clock=0 Enable=1 Condition=0 D=1  ->  Q=0   |  div2: Qd=0
//   t=35  Clock=1 Enable=1 Condition=0 D=1  ->  Q=1   |  div2: Qd=1
//   t=40  Clock=0 Enable=1 Condition=1 D=0  ->  Q=1   |  div2: Qd=1
//   t=45  Clock=1 Enable=1 Condition=1 D=0  ->  Q=1   |  div2: Qd=0
//   t=50  Clock=0 Enable=1 Condition=1 D=0  ->  Q=1   |  div2: Qd=0
//   t=55  Clock=1 Enable=1 Condition=1 D=0  ->  Q=1   |  div2: Qd=1
//   t=60  Clock=0 Enable=1 Condition=1 D=1  ->  Q=1   |  div2: Qd=1
//   t=65  Clock=1 Enable=1 Condition=1 D=1  ->  Q=1   |  div2: Qd=0
//   t=70  Clock=0 Enable=1 Condition=0 D=1  ->  Q=1   |  div2: Qd=0
//   t=75  Clock=1 Enable=1 Condition=0 D=1  ->  Q=1   |  div2: Qd=1
//   t=80  Clock=0 Enable=0 Condition=0 D=1  ->  Q=1   |  div2: Qd=1
//   t=85  Clock=1 Enable=0 Condition=0 D=1  ->  Q=x   |  div2: Qd=0
//   ** Note: $stop    : Enable_FF1_tb.v(32)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Enable_FF1_tb at Enable_FF1_tb.v line 32
//
// 觀察重點：Enable=0 時 Q=x；Enable=1、Condition=0 時 Q 在正緣等於 D；Condition=1 時 Q 保持（t=45~65 D 變了 Q 也不動）；u_div 第一個時脈先載入 0，之後每個正緣反相 = 除 2


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Enable_FF1.v Enable_FF1_tb.v        Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Enable_FF1_tb   Simulate > Start Simulation → work → Enable_FF1_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Enable_FF1_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Enable_FF1.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Enable_FF1_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
