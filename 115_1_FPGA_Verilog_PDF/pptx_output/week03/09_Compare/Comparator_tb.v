`timescale 1ns/1ps

module Comparator_tb;
    reg  [7:0] a, b;
    wire       larger, equal, less;

    Comparator uut (.a(a), .b(b), .larger(larger), .equal(equal), .less(less));

    initial begin
        $monitor("t=%0d  a=%b(%0d) b=%b(%0d)  ->  larger=%b equal=%b less=%b",
                 $time, a, a, b, b, larger, equal, less);
        a = 8'b1111_1111; b = 8'b0000_0001; #10;   // 講義第 63 頁：a > b
        a = 8'b0011_1111; b = 8'b0011_1111; #10;   // 講義第 63 頁：a = b
        a = 8'd3;         b = 8'd200;       #10;   // a < b
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  a=11111111(255) b=00000001(1)  ->  larger=1 equal=0 less=0
//   t=10  a=00111111(63) b=00111111(63)  ->  larger=0 equal=1 less=0
//   t=20  a=00000011(3) b=11001000(200)  ->  larger=0 equal=0 less=1
//   ** Note: $stop    : Comparator_tb.v(15)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Comparator_tb at Comparator_tb.v line 15


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Comparator.v Comparator_tb.v        Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Comparator_tb   Simulate > Start Simulation → work → Comparator_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Comparator_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Comparator.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Comparator_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
