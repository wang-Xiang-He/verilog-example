`timescale 1ns/1ps

// =====================================================================
// Counter2_tb：上數計數器測試平台（講義第 42 頁：Reset → 載入 254 → 254、255、0、1、2 ...）
// =====================================================================
module Counter2_tb;
    reg        Clock, Reset, Load, Enable;
    reg  [7:0] Data_In;
    wire [7:0] Out;

    initial Clock = 1'b0;
    always #5 Clock = ~Clock;           // 週期 10ns，正緣在 5、15、25 ...

    Counter2 uut (.Clock(Clock), .Reset(Reset), .Load(Load), .Enable(Enable), .Data_In(Data_In), .Out(Out));

    always @(negedge Clock)
        $display("t=%0d  Reset=%b Load=%b Enable=%b Data_In=%0d  ->  Out=%0d",
                 $time, Reset, Load, Enable, Data_In, Out);

    initial begin
            Reset = 1; Load = 0; Enable = 1; Data_In = 8'd254;
        #10 Reset = 0; Load = 1;            // 載入 254
        #10 Load  = 0;                      // 開始數
        #60 Enable = 0;                     // 停止計數 → 保持
        #20 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Reset=1 Load=0 Enable=1 Data_In=254  ->  Out=x
//   t=10  Reset=0 Load=1 Enable=1 Data_In=254  ->  Out=0
//   t=20  Reset=0 Load=0 Enable=1 Data_In=254  ->  Out=254
//   t=30  Reset=0 Load=0 Enable=1 Data_In=254  ->  Out=255
//   t=40  Reset=0 Load=0 Enable=1 Data_In=254  ->  Out=0
//   t=50  Reset=0 Load=0 Enable=1 Data_In=254  ->  Out=1
//   t=60  Reset=0 Load=0 Enable=1 Data_In=254  ->  Out=2
//   t=70  Reset=0 Load=0 Enable=1 Data_In=254  ->  Out=3
//   t=80  Reset=0 Load=0 Enable=0 Data_In=254  ->  Out=4
//   t=90  Reset=0 Load=0 Enable=0 Data_In=254  ->  Out=4
//   ** Note: $stop    : Counter2_tb.v(25)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Counter2_tb at Counter2_tb.v line 25
//
// 觀察重點：載入 254 後依序 255、0、1、2 ...（2^8 = 256，255 + 1 回到 0，和講義第 42 頁相同）；Enable=0 之後停在原來的值


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Counter2.v Counter2_tb.v            Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Counter2_tb     Simulate > Start Simulation → work → Counter2_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Counter2_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Counter2.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Counter2_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
