`timescale 1ns/1ps

// =====================================================================
// DFF_RS_tb：DFF_RS 測試平台
//   u1   ：講義第 6 頁的順序：先 Set、再 Reset、再一般的 D 輸入
//   u_div：回答講義第 6 頁「D_FF 具有除 2 功能，如何修正 Testbench 以顯示該項功能？」
//          把 Q_Bar 接回 D → 每個正緣 Q 都反相一次 → Q 的頻率是 Clock 的一半
// =====================================================================
module DFF_RS_tb;
    reg  Clock, Set, Reset, D;
    wire Q, Q_Bar;
    wire Qd, Qd_Bar;

    initial Clock = 1'b0;
    always #5 Clock = ~Clock;           // 週期 10ns，正緣在 5、15、25 ...

    DFF_RS u1    (.Clock(Clock), .Set(Set),  .Reset(Reset), .D(D),      .Q(Q),  .Q_Bar(Q_Bar));
    DFF_RS u_div (.Clock(Clock), .Set(1'b0), .Reset(Reset), .D(Qd_Bar), .Q(Qd), .Q_Bar(Qd_Bar));
    //                                                       ^^^^^^^^ D 接到自己的 Q_Bar

    initial begin
        $monitor("t=%0d  Clock=%b Set=%b Reset=%b D=%b  ->  Q=%b Q_Bar=%b   |  div2: Qd=%b",
                 $time, Clock, Set, Reset, D, Q, Q_Bar, Qd);
            Set = 1; Reset = 0; D = 1;      // 設定 → Q = 1
        #10 Set = 0; Reset = 1;             // 重置 → Q = 0（u_div 也一起重置，Qd 有初值才能開始除 2）
        #10 Reset = 0; D = 1;               // 之後 Q 跟著 D
        #10 D = 0;
        #20 D = 1;
        #20 D = 0;
        #10 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Clock=0 Set=1 Reset=0 D=1  ->  Q=x Q_Bar=x   |  div2: Qd=x
//   t=5  Clock=1 Set=1 Reset=0 D=1  ->  Q=1 Q_Bar=0   |  div2: Qd=x
//   t=10  Clock=0 Set=0 Reset=1 D=1  ->  Q=1 Q_Bar=0   |  div2: Qd=x
//   t=15  Clock=1 Set=0 Reset=1 D=1  ->  Q=0 Q_Bar=1   |  div2: Qd=0
//   t=20  Clock=0 Set=0 Reset=0 D=1  ->  Q=0 Q_Bar=1   |  div2: Qd=0
//   t=25  Clock=1 Set=0 Reset=0 D=1  ->  Q=1 Q_Bar=0   |  div2: Qd=1
//   t=30  Clock=0 Set=0 Reset=0 D=0  ->  Q=1 Q_Bar=0   |  div2: Qd=1
//   t=35  Clock=1 Set=0 Reset=0 D=0  ->  Q=0 Q_Bar=1   |  div2: Qd=0
//   t=40  Clock=0 Set=0 Reset=0 D=0  ->  Q=0 Q_Bar=1   |  div2: Qd=0
//   t=45  Clock=1 Set=0 Reset=0 D=0  ->  Q=0 Q_Bar=1   |  div2: Qd=1
//   t=50  Clock=0 Set=0 Reset=0 D=1  ->  Q=0 Q_Bar=1   |  div2: Qd=1
//   t=55  Clock=1 Set=0 Reset=0 D=1  ->  Q=1 Q_Bar=0   |  div2: Qd=0
//   t=60  Clock=0 Set=0 Reset=0 D=1  ->  Q=1 Q_Bar=0   |  div2: Qd=0
//   t=65  Clock=1 Set=0 Reset=0 D=1  ->  Q=1 Q_Bar=0   |  div2: Qd=1
//   t=70  Clock=0 Set=0 Reset=0 D=0  ->  Q=1 Q_Bar=0   |  div2: Qd=1
//   t=75  Clock=1 Set=0 Reset=0 D=0  ->  Q=0 Q_Bar=1   |  div2: Qd=0
//   ** Note: $stop    : DFF_RS_tb.v(30)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module DFF_RS_tb at DFF_RS_tb.v line 30
//
// 觀察重點：u1：t=5 Set → Q=1、t=15 Reset → Q=0，之後每個正緣 Q = D、Q_Bar = ~D；u_div：重置後每個正緣 Qd 反相一次，Qd 的週期 20ns 是 Clock（10ns）的兩倍 = 除 2


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog DFF_RS.v DFF_RS_tb.v                Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.DFF_RS_tb       Simulate > Start Simulation → work → DFF_RS_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 DFF_RS_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 DFF_RS.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, DFF_RS_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
