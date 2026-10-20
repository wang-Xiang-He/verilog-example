`timescale 1ns/1ps

// =====================================================================
// SIPO_tb：兩種串進並出寫法一起測
//   SI 依序 1 0 1 0 1 1 1 → Data_Out = 0001、0010、0101、1010、0101、1011、0111（講義第 26 頁波形）
// =====================================================================
module SIPO_tb;
    reg        Clock, Clear, SI;
    wire [3:0] Data_Out, Data_Out_1;

    initial Clock = 1'b0;
    always #5 Clock = ~Clock;           // 週期 10ns，正緣在 5、15、25 ...

    SIPO_Shift_Register   u0 (.Clock(Clock), .Clear(Clear), .SI(SI), .Data_Out(Data_Out));
    SIPO_Shift_Register_1 u1 (.Clock(Clock), .Clear(Clear), .SI(SI), .Data_Out(Data_Out_1));

    always @(negedge Clock)
        $display("t=%0d  Clear=%b SI=%b  ->  Data_Out=%b   |  _1 (temp): Data_Out=%b  temp=%b",
                 $time, Clear, SI, Data_Out, Data_Out_1, u1.temp);

    initial begin
            Clear = 1; SI = 0;
        #10 Clear = 0; SI = 1;
        #10 SI = 0;
        #10 SI = 1;
        #10 SI = 0;
        #10 SI = 1;
        #10 SI = 1;
        #10 SI = 1;
        #20 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Clear=1 SI=0  ->  Data_Out=xxxx   |  _1 (temp): Data_Out=xxxx  temp=xxxx
//   t=10  Clear=0 SI=1  ->  Data_Out=0000   |  _1 (temp): Data_Out=0000  temp=0000
//   t=20  Clear=0 SI=0  ->  Data_Out=0001   |  _1 (temp): Data_Out=0000  temp=0001
//   t=30  Clear=0 SI=1  ->  Data_Out=0010   |  _1 (temp): Data_Out=0001  temp=0010
//   t=40  Clear=0 SI=0  ->  Data_Out=0101   |  _1 (temp): Data_Out=0010  temp=0101
//   t=50  Clear=0 SI=1  ->  Data_Out=1010   |  _1 (temp): Data_Out=0101  temp=1010
//   t=60  Clear=0 SI=1  ->  Data_Out=0101   |  _1 (temp): Data_Out=1010  temp=0101
//   t=70  Clear=0 SI=1  ->  Data_Out=1011   |  _1 (temp): Data_Out=0101  temp=1011
//   t=80  Clear=0 SI=1  ->  Data_Out=0111   |  _1 (temp): Data_Out=1011  temp=0111
//   ** Note: $stop    : SIPO_tb.v(30)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module SIPO_tb at SIPO_tb.v line 30
//
// 觀察重點：Data_Out 依序 0001、0010、0101、1010、0101、1011、0111，和講義第 26 頁相同；_1（temp 版）先並出再串進，每個值都晚一個時脈出現（講義第 28 頁下面那張波形）


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog SIPO_Shift_Register.v SIPO_Shift_Register_1.v SIPO_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.SIPO_tb         Simulate > Start Simulation → work → SIPO_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 SIPO_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 SIPO_Shift_Register.v、SIPO_Shift_Register_1.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, SIPO_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
