`timescale 1ns/1ps

// =====================================================================
// Counter6_tb：上數 / 下數計數器測試平台
//   載入 254 → 上數經過 255 → 0 → 1 → 改下數經過 0 → 255 → 254 → Enable = 0 停住
// =====================================================================
module Counter6_tb;
    reg        Clock, Reset, Load, Enable, Up_Down;
    reg  [7:0] Data_In;
    wire [7:0] Out;

    initial Clock = 1'b0;
    always #5 Clock = ~Clock;           // 週期 10ns，正緣在 5、15、25 ...

    Counter6 uut (.Clock(Clock), .Reset(Reset), .Load(Load), .Enable(Enable), .Up_Down(Up_Down),
                  .Data_In(Data_In), .Out(Out));

    always @(negedge Clock)
        $display("t=%0d  Reset=%b Load=%b Enable=%b Up_Down=%b  ->  Out=%0d",
                 $time, Reset, Load, Enable, Up_Down, Out);

    initial begin
            Reset = 1; Load = 0; Enable = 1; Up_Down = 1; Data_In = 8'd254;
        #10 Reset = 0; Load = 1;            // 載入 254
        #10 Load = 0;                       // 上數
        #30 Up_Down = 0;                    // 下數
        #40 Enable = 0;                     // 停住
        #20 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Reset=1 Load=0 Enable=1 Up_Down=1  ->  Out=x
//   t=10  Reset=0 Load=1 Enable=1 Up_Down=1  ->  Out=0
//   t=20  Reset=0 Load=0 Enable=1 Up_Down=1  ->  Out=254
//   t=30  Reset=0 Load=0 Enable=1 Up_Down=1  ->  Out=255
//   t=40  Reset=0 Load=0 Enable=1 Up_Down=1  ->  Out=0
//   t=50  Reset=0 Load=0 Enable=1 Up_Down=0  ->  Out=1
//   t=60  Reset=0 Load=0 Enable=1 Up_Down=0  ->  Out=0
//   t=70  Reset=0 Load=0 Enable=1 Up_Down=0  ->  Out=255
//   t=80  Reset=0 Load=0 Enable=1 Up_Down=0  ->  Out=254
//   t=90  Reset=0 Load=0 Enable=0 Up_Down=0  ->  Out=253
//   t=100  Reset=0 Load=0 Enable=0 Up_Down=0  ->  Out=253
//   ** Note: $stop    : Counter6_tb.v(28)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Counter6_tb at Counter6_tb.v line 28
//
// 觀察重點：上數 254 → 255 → 0 → 1，改下數後 1 → 0 → 255 → 254（8 位元在 0 和 255 之間繞圈）；Enable=0 時保持；Load 優先於計數


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Counter6.v Counter6_tb.v            Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Counter6_tb     Simulate > Start Simulation → work → Counter6_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Counter6_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Counter6.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Counter6_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
