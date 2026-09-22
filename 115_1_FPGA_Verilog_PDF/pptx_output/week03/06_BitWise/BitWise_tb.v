`timescale 1ns/1ps

module BitWise_tb;
    reg  [7:0] input_bus;
    wire       even, odd, all_one;

    BitWise uut (.input_bus(input_bus), .even(even), .odd(odd), .all_one(all_one));

    initial begin
        $monitor("t=%0d  input_bus=%b  ->  odd=%b even=%b all_one=%b",
                 $time, input_bus, odd, even, all_one);
        input_bus = 8'b1111_1111; #10;   // 講義第 50 頁模擬的第 1 組
        input_bus = 8'b1010_1010; #10;   // 講義第 50 頁模擬的第 2 組
        input_bus = 8'b0000_0111; #10;
        input_bus = 8'b0000_0000; #10;
        $stop;
    end
    // 對照：11111111 有 8 個 1（偶數）、10101010 有 4 個 1（偶數）、00000111 有 3 個 1（奇數）
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  input_bus=11111111  ->  odd=0 even=1 all_one=1
//   t=10  input_bus=10101010  ->  odd=0 even=1 all_one=0
//   t=20  input_bus=00000111  ->  odd=1 even=0 all_one=0
//   t=30  input_bus=00000000  ->  odd=0 even=1 all_one=0
//   ** Note: $stop    : BitWise_tb.v(16)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module BitWise_tb at BitWise_tb.v line 16


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog BitWise.v BitWise_tb.v              Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.BitWise_tb      Simulate > Start Simulation → work → BitWise_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 BitWise_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 BitWise.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, BitWise_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
