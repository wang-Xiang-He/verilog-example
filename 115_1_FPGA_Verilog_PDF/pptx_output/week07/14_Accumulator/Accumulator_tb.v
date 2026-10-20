`timescale 1ns/1ps

// =====================================================================
// Accumulator_tb：累加器測試平台
//   數值 = 講義第 63 頁：Data_In 依序 3、3、4、5 → Out = 3、6、10、15
//   另外在中間故意讓 Reset 在「時脈中間」變成 1，看非同步重置是不是馬上清 0
// =====================================================================
module Accumulator_tb;
    reg         Clock, Reset;
    reg  [15:0] Data_In;
    wire [15:0] Out;

    Accumulator uut (.Clock(Clock), .Reset(Reset), .Data_In(Data_In), .Out(Out));

    initial Clock = 1'b0;
    always #10 Clock = ~Clock;      // 正緣在 10、30、50 ...

    initial begin
        $monitor("t=%0d  Clock=%b Reset=%b  Data_In=%b(%0d)  ->  Out=%b(%0d)",
                 $time, Clock, Reset, Data_In, Data_In, Out, Out);
        Reset = 1'b1; Data_In = 16'd3;      // 一開始先重置
        #5  Reset = 1'b0;
        #20 Data_In = 16'd3;                // t=25（10 的正緣後）：下一次 +3
        #20 Data_In = 16'd4;                // t=45
        #20 Data_In = 16'd5;                // t=65
        #20 Data_In = 16'd1;                // t=85
        #10 Reset = 1'b1;                   // t=95：時脈中間重置 → Out 立刻變 0
        #10 Reset = 1'b0;                   // t=105
        #30 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Clock=0 Reset=1  Data_In=0000000000000011(3)  ->  Out=0000000000000000(0)
//   t=5  Clock=0 Reset=0  Data_In=0000000000000011(3)  ->  Out=0000000000000000(0)
//   t=10  Clock=1 Reset=0  Data_In=0000000000000011(3)  ->  Out=0000000000000011(3)
//   t=20  Clock=0 Reset=0  Data_In=0000000000000011(3)  ->  Out=0000000000000011(3)
//   t=30  Clock=1 Reset=0  Data_In=0000000000000011(3)  ->  Out=0000000000000110(6)
//   t=40  Clock=0 Reset=0  Data_In=0000000000000011(3)  ->  Out=0000000000000110(6)
//   t=45  Clock=0 Reset=0  Data_In=0000000000000100(4)  ->  Out=0000000000000110(6)
//   t=50  Clock=1 Reset=0  Data_In=0000000000000100(4)  ->  Out=0000000000001010(10)
//   t=60  Clock=0 Reset=0  Data_In=0000000000000100(4)  ->  Out=0000000000001010(10)
//   t=65  Clock=0 Reset=0  Data_In=0000000000000101(5)  ->  Out=0000000000001010(10)
//   t=70  Clock=1 Reset=0  Data_In=0000000000000101(5)  ->  Out=0000000000001111(15)
//   t=80  Clock=0 Reset=0  Data_In=0000000000000101(5)  ->  Out=0000000000001111(15)
//   t=85  Clock=0 Reset=0  Data_In=0000000000000001(1)  ->  Out=0000000000001111(15)
//   t=90  Clock=1 Reset=0  Data_In=0000000000000001(1)  ->  Out=0000000000010000(16)
//   t=95  Clock=1 Reset=1  Data_In=0000000000000001(1)  ->  Out=0000000000000000(0)
//   t=100  Clock=0 Reset=1  Data_In=0000000000000001(1)  ->  Out=0000000000000000(0)
//   t=105  Clock=0 Reset=0  Data_In=0000000000000001(1)  ->  Out=0000000000000000(0)
//   t=110  Clock=1 Reset=0  Data_In=0000000000000001(1)  ->  Out=0000000000000001(1)
//   t=120  Clock=0 Reset=0  Data_In=0000000000000001(1)  ->  Out=0000000000000001(1)
//   t=130  Clock=1 Reset=0  Data_In=0000000000000001(1)  ->  Out=0000000000000010(2)
//   ** Note: $stop    : Accumulator_tb.v(29)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Accumulator_tb at Accumulator_tb.v line 29
//
// 觀察重點：Out 在每個正緣加上 Data_In：0→3→6→10→15→16（講義第 63 頁的 0011、0110、1010、1111）；t=95 Reset 一變 1，Out 不等時脈就立刻清 0（非同步重置）


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Accumulator.v Accumulator_tb.v      Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Accumulator_tb  Simulate > Start Simulation → work → Accumulator_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Accumulator_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Accumulator.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Accumulator_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
