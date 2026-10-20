`timescale 1ns/1ps

// =====================================================================
// D_FF_SR_tb：同步重置 D 型正反器測試平台
//   測試順序和 04_DFF_PR 的 Reset 部分相同：Reset 在兩個正緣中間變成 0
// =====================================================================
module D_FF_SR_tb;
    reg  Clock, Reset, D;
    wire Q;

    initial Clock = 1'b0;
    always #5 Clock = ~Clock;           // 週期 10ns，正緣在 5、15、25 ...

    D_FF_SR uut (.Clock(Clock), .Reset(Reset), .D(D), .Q(Q));

    initial begin
        $monitor("t=%0d  Clock=%b Reset=%b D=%b  ->  Q=%b", $time, Clock, Reset, D, Q);
            Reset = 1; D = 1;
        #12 Reset = 0;                      // t=12：Q 不會馬上變，要等 t=15 的正緣
        #10 Reset = 1;                      // t=22
        #10 D = 0;                          // t=32
        #20 D = 1;                          // t=52
        #10 Reset = 0;                      // t=62：Q 不會馬上變，等到 t=65 的正緣才清 0
        #10 Reset = 1;                      // t=72
        #10 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Clock=0 Reset=1 D=1  ->  Q=x
//   t=5  Clock=1 Reset=1 D=1  ->  Q=1
//   t=10  Clock=0 Reset=1 D=1  ->  Q=1
//   t=12  Clock=0 Reset=0 D=1  ->  Q=1
//   t=15  Clock=1 Reset=0 D=1  ->  Q=0
//   t=20  Clock=0 Reset=0 D=1  ->  Q=0
//   t=22  Clock=0 Reset=1 D=1  ->  Q=0
//   t=25  Clock=1 Reset=1 D=1  ->  Q=1
//   t=30  Clock=0 Reset=1 D=1  ->  Q=1
//   t=32  Clock=0 Reset=1 D=0  ->  Q=1
//   t=35  Clock=1 Reset=1 D=0  ->  Q=0
//   t=40  Clock=0 Reset=1 D=0  ->  Q=0
//   t=45  Clock=1 Reset=1 D=0  ->  Q=0
//   t=50  Clock=0 Reset=1 D=0  ->  Q=0
//   t=52  Clock=0 Reset=1 D=1  ->  Q=0
//   t=55  Clock=1 Reset=1 D=1  ->  Q=1
//   t=60  Clock=0 Reset=1 D=1  ->  Q=1
//   t=62  Clock=0 Reset=0 D=1  ->  Q=1
//   t=65  Clock=1 Reset=0 D=1  ->  Q=0
//   t=70  Clock=0 Reset=0 D=1  ->  Q=0
//   t=72  Clock=0 Reset=1 D=1  ->  Q=0
//   t=75  Clock=1 Reset=1 D=1  ->  Q=1
//   t=80  Clock=0 Reset=1 D=1  ->  Q=1
//   ** Note: $stop    : D_FF_SR_tb.v(25)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module D_FF_SR_tb at D_FF_SR_tb.v line 25
//
// 觀察重點：t=12 Reset 變 0，但 Q 要到 t=15 的正緣才變 0（同步）；和 04_DFF_PR 比較：非同步重置在 t=12 就立刻清 0


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog D_FF_SR.v D_FF_SR_tb.v              Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.D_FF_SR_tb      Simulate > Start Simulation → work → D_FF_SR_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 D_FF_SR_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 D_FF_SR.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, D_FF_SR_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
