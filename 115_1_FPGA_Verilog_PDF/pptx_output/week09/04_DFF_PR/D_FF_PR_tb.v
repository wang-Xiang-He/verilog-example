`timescale 1ns/1ps

// =====================================================================
// D_FF_PR_tb：非同步重置 / 預設 D 型正反器測試平台
//   Reset、Preset 故意在「兩個正緣中間」變成 0，看 Q 是不是馬上改變
//   和 05_DFF_SR（同步重置）用同樣的測試順序，可以對照
// =====================================================================
module D_FF_PR_tb;
    reg  Clock, Reset, Preset, D;
    wire Q;

    initial Clock = 1'b0;
    always #5 Clock = ~Clock;           // 週期 10ns，正緣在 5、15、25 ...

    D_FF_PR uut (.Clock(Clock), .Reset(Reset), .Preset(Preset), .D(D), .Q(Q));

    initial begin
        $monitor("t=%0d  Clock=%b Reset=%b Preset=%b D=%b  ->  Q=%b", $time, Clock, Reset, Preset, D, Q);
            Reset = 1; Preset = 1; D = 1;
        #12 Reset = 0;                      // t=12：兩個正緣（5、15）中間 → Q 立刻 = 0
        #10 Reset = 1;                      // t=22
        #10 D = 0;                          // t=32
        #10 Preset = 0;                     // t=42：Q 立刻 = 1
        #10 Preset = 1;                     // t=52
        #10 D = 1;                          // t=62
        #10 D = 0;                          // t=72
        #13 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Clock=0 Reset=1 Preset=1 D=1  ->  Q=x
//   t=5  Clock=1 Reset=1 Preset=1 D=1  ->  Q=1
//   t=10  Clock=0 Reset=1 Preset=1 D=1  ->  Q=1
//   t=12  Clock=0 Reset=0 Preset=1 D=1  ->  Q=0
//   t=15  Clock=1 Reset=0 Preset=1 D=1  ->  Q=0
//   t=20  Clock=0 Reset=0 Preset=1 D=1  ->  Q=0
//   t=22  Clock=0 Reset=1 Preset=1 D=1  ->  Q=0
//   t=25  Clock=1 Reset=1 Preset=1 D=1  ->  Q=1
//   t=30  Clock=0 Reset=1 Preset=1 D=1  ->  Q=1
//   t=32  Clock=0 Reset=1 Preset=1 D=0  ->  Q=1
//   t=35  Clock=1 Reset=1 Preset=1 D=0  ->  Q=0
//   t=40  Clock=0 Reset=1 Preset=1 D=0  ->  Q=0
//   t=42  Clock=0 Reset=1 Preset=0 D=0  ->  Q=1
//   t=45  Clock=1 Reset=1 Preset=0 D=0  ->  Q=1
//   t=50  Clock=0 Reset=1 Preset=0 D=0  ->  Q=1
//   t=52  Clock=0 Reset=1 Preset=1 D=0  ->  Q=1
//   t=55  Clock=1 Reset=1 Preset=1 D=0  ->  Q=0
//   t=60  Clock=0 Reset=1 Preset=1 D=0  ->  Q=0
//   t=62  Clock=0 Reset=1 Preset=1 D=1  ->  Q=0
//   t=65  Clock=1 Reset=1 Preset=1 D=1  ->  Q=1
//   t=70  Clock=0 Reset=1 Preset=1 D=1  ->  Q=1
//   t=72  Clock=0 Reset=1 Preset=1 D=0  ->  Q=1
//   t=75  Clock=1 Reset=1 Preset=1 D=0  ->  Q=0
//   t=80  Clock=0 Reset=1 Preset=1 D=0  ->  Q=0
//   ** Note: $stop    : D_FF_PR_tb.v(27)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module D_FF_PR_tb at D_FF_PR_tb.v line 27
//
// 觀察重點：t=12 Reset 變 0、t=42 Preset 變 0 時，Q 都在同一個時間點立刻改變（非同步）；Reset、Preset 都是 1 時才在正緣跟著 D


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog D_FF_PR.v D_FF_PR_tb.v              Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.D_FF_PR_tb      Simulate > Start Simulation → work → D_FF_PR_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 D_FF_PR_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 D_FF_PR.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, D_FF_PR_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
