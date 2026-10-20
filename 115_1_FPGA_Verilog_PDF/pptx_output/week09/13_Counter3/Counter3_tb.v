`timescale 1ns/1ps

// =====================================================================
// Counter3_tb：Counter3 測試平台（講義第 45 頁：載入 11111110 → 11111110、11111111、00000000 ...）
// =====================================================================
module Counter3_tb;
    reg        Clock, Load, Carry_In;
    reg  [7:0] Data_In;
    wire [7:0] Out;
    wire       Carry_Out;

    initial Clock = 1'b0;
    always #5 Clock = ~Clock;           // 週期 10ns，正緣在 5、15、25 ...

    Counter3 uut (.Clock(Clock), .Load(Load), .Carry_In(Carry_In), .Data_In(Data_In),
                  .Out(Out), .Carry_Out(Carry_Out));

    always @(negedge Clock)
        $display("t=%0d  Load=%b Carry_In=%b Data_In=%b  ->  Out=%b (%0d)  Pre_Out=%b  Carry_Out=%b",
                 $time, Load, Carry_In, Data_In, Out, Out, uut.Pre_Out, Carry_Out);

    initial begin
            Load = 1; Carry_In = 1; Data_In = 8'b1111_1110;    // 載入 254
        #10 Load = 0;
        #40 Carry_In = 0;                                       // 不再計數
        #20 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Load=1 Carry_In=1 Data_In=11111110  ->  Out=xxxxxxxx (x)  Pre_Out=11111110  Carry_Out=x
//   t=10  Load=0 Carry_In=1 Data_In=11111110  ->  Out=11111110 (254)  Pre_Out=11111111  Carry_Out=0
//   t=20  Load=0 Carry_In=1 Data_In=11111110  ->  Out=11111111 (255)  Pre_Out=00000000  Carry_Out=1
//   t=30  Load=0 Carry_In=1 Data_In=11111110  ->  Out=00000000 (0)  Pre_Out=00000001  Carry_Out=0
//   t=40  Load=0 Carry_In=1 Data_In=11111110  ->  Out=00000001 (1)  Pre_Out=00000010  Carry_Out=0
//   t=50  Load=0 Carry_In=0 Data_In=11111110  ->  Out=00000010 (2)  Pre_Out=00000010  Carry_Out=0
//   t=60  Load=0 Carry_In=0 Data_In=11111110  ->  Out=00000010 (2)  Pre_Out=00000010  Carry_Out=0
//   ** Note: $stop    : Counter3_tb.v(26)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Counter3_tb at Counter3_tb.v line 26
//
// 觀察重點：Out = 254 → 255 → 0 → 1；Carry_Out 在 Out=255（而且 Carry_In=1）的那一個時脈為 1，表示「下一個正緣會進位歸零」——講義第 45 頁標 Wrong? 的位置，其實是組合邏輯提前算出的進位；一開始 Out 還沒有值時 Carry_Out 是 x


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Counter3.v Counter3_tb.v            Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Counter3_tb     Simulate > Start Simulation → work → Counter3_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Counter3_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Counter3.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Counter3_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
