`timescale 1ns/1ps

module deco2_4g_tb;
    reg        a, b;
    wire [3:0] y;

    deco2_4g dec (.a(a), .b(b), .y(y));

    initial begin
        $monitor("t=%0d  b=%b a=%b  ->  y3..y0=%b", $time, b, a, y);
        b = 0; a = 0;
        #10 b = 0; a = 1;
        #10 b = 1; a = 0;
        #10 b = 1; a = 1;
        #10 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  b=0 a=0  ->  y3..y0=0001
//   t=10  b=0 a=1  ->  y3..y0=0010
//   t=20  b=1 a=0  ->  y3..y0=0100
//   t=30  b=1 a=1  ->  y3..y0=1000
//   ** Note: $stop    : deco2_4g_tb.v(15)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module deco2_4g_tb at deco2_4g_tb.v line 15


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog deco2_4g.v deco2_4g_tb.v            Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.deco2_4g_tb     Simulate > Start Simulation → work → deco2_4g_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 deco2_4g_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 deco2_4g.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, deco2_4g_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
