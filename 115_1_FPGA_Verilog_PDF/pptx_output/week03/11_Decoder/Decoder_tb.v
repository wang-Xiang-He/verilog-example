`timescale 1ns/1ps

module Decoder_tb;
    reg  [2:0] in;
    wire [7:0] Out;
    integer    i;

    Decoder uut (.in(in), .Out(Out));

    initial begin
        $monitor("t=%0d  in=%b(%0d)  ->  Out=%b", $time, in, in, Out);
        for (i = 0; i < 8; i = i + 1) begin
            in = i; #10;
        end
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  in=000(0)  ->  Out=00000001
//   t=10  in=001(1)  ->  Out=00000010
//   t=20  in=010(2)  ->  Out=00000100
//   t=30  in=011(3)  ->  Out=00001000
//   t=40  in=100(4)  ->  Out=00010000
//   t=50  in=101(5)  ->  Out=00100000
//   t=60  in=110(6)  ->  Out=01000000
//   t=70  in=111(7)  ->  Out=10000000
//   ** Note: $stop    : Decoder_tb.v(15)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Decoder_tb at Decoder_tb.v line 15


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Decoder.v Decoder_tb.v              Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Decoder_tb      Simulate > Start Simulation → work → Decoder_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Decoder_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Decoder.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Decoder_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
