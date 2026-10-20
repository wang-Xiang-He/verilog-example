`timescale 1ns/1ps

// =====================================================================
// PIPO_tb：三種 PIPO 寫法一起測
//   Data_In 依序 1101、1111、1001、0111、0010（講義第 35、37、39 頁波形），之後 Load = 0
// =====================================================================
module PIPO_tb;
    reg        Clock, Clear, Load;
    reg  [3:0] Data_In;
    wire [3:0] Out0, Out1, Out2;

    initial Clock = 1'b0;
    always #5 Clock = ~Clock;           // 週期 10ns，正緣在 5、15、25 ...

    PIPO_Shift_Register       u0 (.Clock(Clock), .Clear(Clear), .Load(Load), .Data_In(Data_In), .Data_Out(Out0));
    PIPO_Shift_Register_new01 u1 (.Clock(Clock), .Clear(Clear), .Load(Load), .Data_In(Data_In), .Data_Out(Out1));
    PIPO_Shift_Register_new02 u2 (.Clock(Clock), .Clear(Clear), .Load(Load), .Data_In(Data_In), .Data_Out(Out2));

    always @(negedge Clock)
        $display("t=%0d  Clear=%b Load=%b Data_In=%b  ->  original=%b   new01=%b (temp=%b)   new02=%b",
                 $time, Clear, Load, Data_In, Out0, Out1, u1.temp, Out2);

    initial begin
            Clear = 1; Load = 0; Data_In = 4'b0000;
        #10 Clear = 0; Load = 1; Data_In = 4'b1101;
        #10 Data_In = 4'b1111;
        #10 Data_In = 4'b1001;
        #10 Data_In = 4'b0111;
        #10 Data_In = 4'b0010;
        #10 Load = 0;
        #20 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Clear=1 Load=0 Data_In=0000  ->  original=xxxx   new01=xxxx (temp=xxxx)   new02=xxxx
//   t=10  Clear=0 Load=1 Data_In=1101  ->  original=0000   new01=0000 (temp=xxxx)   new02=0000
//   t=20  Clear=0 Load=1 Data_In=1111  ->  original=1101   new01=xxxx (temp=1101)   new02=1101
//   t=30  Clear=0 Load=1 Data_In=1001  ->  original=1111   new01=1101 (temp=1111)   new02=1111
//   t=40  Clear=0 Load=1 Data_In=0111  ->  original=1001   new01=1111 (temp=1001)   new02=1001
//   t=50  Clear=0 Load=1 Data_In=0010  ->  original=0111   new01=1001 (temp=0111)   new02=0111
//   t=60  Clear=0 Load=0 Data_In=0010  ->  original=0010   new01=0111 (temp=0010)   new02=0010
//   t=70  Clear=0 Load=0 Data_In=0010  ->  original=0010   new01=0111 (temp=0010)   new02=0010
//   ** Note: $stop    : PIPO_tb.v(31)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module PIPO_tb at PIPO_tb.v line 31
//
// 觀察重點：original 和 new02 每一行都一樣（wire temp 沒有記憶）；new01 晚一個時脈，第一次載入時 temp 還沒有值，所以拿到 x（講義第 37 頁紅色那段），而且 Load=0 之後最後一筆 0010 留在 temp 裡出不來


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog PIPO_Shift_Register.v PIPO_Shift_Register_new01.v PIPO_Shift_Register_new02.v PIPO_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.PIPO_tb         Simulate > Start Simulation → work → PIPO_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 PIPO_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 PIPO_Shift_Register.v、PIPO_Shift_Register_new01.v、PIPO_Shift_Register_new02.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, PIPO_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
