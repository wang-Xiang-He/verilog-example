`timescale 1ns/1ps

module Mux2to1_tb;
    reg  a, b, Select;
    wire Out;
    integer i;

    Mux2to1 uut (.a(a), .b(b), .Select(Select), .Out(Out));

    initial begin
        $monitor("t=%0d  Select=%b a=%b b=%b  ->  Out=%b", $time, Select, a, b, Out);
        for (i = 0; i < 8; i = i + 1) begin
            {Select, a, b} = i; #10;
        end
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Select=0 a=0 b=0  ->  Out=0
//   t=10  Select=0 a=0 b=1  ->  Out=1
//   t=20  Select=0 a=1 b=0  ->  Out=0
//   t=30  Select=0 a=1 b=1  ->  Out=1
//   t=40  Select=1 a=0 b=0  ->  Out=0
//   t=50  Select=1 a=0 b=1  ->  Out=0
//   t=60  Select=1 a=1 b=0  ->  Out=1
//   t=70  Select=1 a=1 b=1  ->  Out=1
//   ** Note: $stop    : Mux2to1_tb.v(15)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Mux2to1_tb at Mux2to1_tb.v line 15


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Mux2to1.v Mux2to1_tb.v              Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Mux2to1_tb      Simulate > Start Simulation → work → Mux2to1_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Mux2to1_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Mux2to1.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Mux2to1_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
