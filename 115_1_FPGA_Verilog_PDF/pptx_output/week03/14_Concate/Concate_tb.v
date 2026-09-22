`timescale 1ns/1ps

module Concate_tb;
    reg        swap;
    reg  [3:0] byte1, byte2;
    wire [7:0] word;

    Concate uut (.swap(swap), .byte1(byte1), .byte2(byte2), .word(word));

    initial begin
        $monitor("t=%0d  swap=%b byte1=%b byte2=%b  ->  word=%b",
                 $time, swap, byte1, byte2, word);
        byte1 = 4'b1000; byte2 = 4'b0001;            // 講義第 75 頁的值
        swap = 1; #10;                               // → 0001_1000
        swap = 0; #10;                               // → 1000_0001
        byte1 = 4'b0101; byte2 = 4'b1010;            // 講義第 76 頁模擬的值
        swap = 1; #10;
        swap = 0; #10;
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  swap=1 byte1=1000 byte2=0001  ->  word=00011000
//   t=10  swap=0 byte1=1000 byte2=0001  ->  word=10000001
//   t=20  swap=1 byte1=0101 byte2=1010  ->  word=10100101
//   t=30  swap=0 byte1=0101 byte2=1010  ->  word=01011010
//   ** Note: $stop    : Concate_tb.v(19)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Concate_tb at Concate_tb.v line 19


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Concate.v Concate_tb.v              Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Concate_tb      Simulate > Start Simulation → work → Concate_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Concate_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Concate.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Concate_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
