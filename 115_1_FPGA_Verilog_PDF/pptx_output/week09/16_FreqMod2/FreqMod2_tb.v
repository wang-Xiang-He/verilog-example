`timescale 1ns/1ps

// =====================================================================
// FreqMod2_tb：除 2 器測試平台（Clock_In 週期 10ns → Clock_Mod2_Out 週期應為 20ns）
// =====================================================================
module FreqMod2_tb;
    reg  Reset, Clock_In;
    wire Clock_Mod2_Out;

    initial Clock_In = 1'b0;
    always #5 Clock_In = ~Clock_In;

    FreqMod2 uut (.Reset(Reset), .Clock_In(Clock_In), .Clock_Mod2_Out(Clock_Mod2_Out));

    initial begin
        $monitor("t=%0d  Reset=%b Clock_In=%b  ->  Clock_Mod2_Out=%b", $time, Reset, Clock_In, Clock_Mod2_Out);
            Reset = 1;
        #12 Reset = 0;
        #60 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Reset=1 Clock_In=0  ->  Clock_Mod2_Out=0
//   t=5  Reset=1 Clock_In=1  ->  Clock_Mod2_Out=0
//   t=10  Reset=1 Clock_In=0  ->  Clock_Mod2_Out=0
//   t=12  Reset=0 Clock_In=0  ->  Clock_Mod2_Out=0
//   t=15  Reset=0 Clock_In=1  ->  Clock_Mod2_Out=1
//   t=20  Reset=0 Clock_In=0  ->  Clock_Mod2_Out=1
//   t=25  Reset=0 Clock_In=1  ->  Clock_Mod2_Out=0
//   t=30  Reset=0 Clock_In=0  ->  Clock_Mod2_Out=0
//   t=35  Reset=0 Clock_In=1  ->  Clock_Mod2_Out=1
//   t=40  Reset=0 Clock_In=0  ->  Clock_Mod2_Out=1
//   t=45  Reset=0 Clock_In=1  ->  Clock_Mod2_Out=0
//   t=50  Reset=0 Clock_In=0  ->  Clock_Mod2_Out=0
//   t=55  Reset=0 Clock_In=1  ->  Clock_Mod2_Out=1
//   t=60  Reset=0 Clock_In=0  ->  Clock_Mod2_Out=1
//   t=65  Reset=0 Clock_In=1  ->  Clock_Mod2_Out=0
//   t=70  Reset=0 Clock_In=0  ->  Clock_Mod2_Out=0
//   ** Note: $stop    : FreqMod2_tb.v(19)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module FreqMod2_tb at FreqMod2_tb.v line 19
//
// 觀察重點：Reset 之後 Clock_Mod2_Out 在每個 Clock_In 正緣（15、25、35 ...）反相一次，所以輸出每 20ns 一個週期，是輸入的 2 倍（講義第 54 頁的 0→1→0→1）


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog FreqMod2.v FreqMod2_tb.v            Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.FreqMod2_tb     Simulate > Start Simulation → work → FreqMod2_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 FreqMod2_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 FreqMod2.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, FreqMod2_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
