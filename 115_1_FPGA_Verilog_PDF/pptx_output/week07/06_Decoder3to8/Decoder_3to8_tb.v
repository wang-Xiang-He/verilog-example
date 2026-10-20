`timescale 1ns/1ps

// =====================================================================
// Decoder_3to8_tb：3 對 8 解碼器測試平台
//   和講義第 27 頁波形一樣：先 G = 1（不致能）跑一次 000~111，再 G = 0 跑一次
// =====================================================================
module Decoder_3to8_tb;
    reg  A2, A1, A0, G;
    wire D7, D6, D5, D4, D3, D2, D1, D0;
    integer k;

    Decoder_3to8 uut (A2, A1, A0, G, D7, D6, D5, D4, D3, D2, D1, D0);

    initial begin
        $monitor("t=%0d  G=%b A2A1A0=%b%b%b  ->  D7..D0=%b%b%b%b%b%b%b%b",
                 $time, G, A2, A1, A0, D7, D6, D5, D4, D3, D2, D1, D0);
        G = 1'b1;                               // 不致能：輸出全部是 1
        for (k = 0; k < 8; k = k + 1) begin
            {A2, A1, A0} = k; #10;
        end
        G = 1'b0;                               // 致能
        for (k = 0; k < 8; k = k + 1) begin
            {A2, A1, A0} = k; #10;
        end
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  G=1 A2A1A0=000  ->  D7..D0=11111111
//   t=10  G=1 A2A1A0=001  ->  D7..D0=11111111
//   t=20  G=1 A2A1A0=010  ->  D7..D0=11111111
//   t=30  G=1 A2A1A0=011  ->  D7..D0=11111111
//   t=40  G=1 A2A1A0=100  ->  D7..D0=11111111
//   t=50  G=1 A2A1A0=101  ->  D7..D0=11111111
//   t=60  G=1 A2A1A0=110  ->  D7..D0=11111111
//   t=70  G=1 A2A1A0=111  ->  D7..D0=11111111
//   t=80  G=0 A2A1A0=000  ->  D7..D0=11111110
//   t=90  G=0 A2A1A0=001  ->  D7..D0=11111101
//   t=100  G=0 A2A1A0=010  ->  D7..D0=11111011
//   t=110  G=0 A2A1A0=011  ->  D7..D0=11110111
//   t=120  G=0 A2A1A0=100  ->  D7..D0=11101111
//   t=130  G=0 A2A1A0=101  ->  D7..D0=11011111
//   t=140  G=0 A2A1A0=110  ->  D7..D0=10111111
//   t=150  G=0 A2A1A0=111  ->  D7..D0=01111111
//   ** Note: $stop    : Decoder_3to8_tb.v(25)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Decoder_3to8_tb at Decoder_3to8_tb.v line 25
//
// 觀察重點：G=1 時不管 A 是多少，D7..D0 都是 11111111；G=0 時只有第 A 條輸出是 0（低態輸出），0 的位置從 D0 一路往左移到 D7


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Decoder_3to8.v Decoder_3to8_tb.v    Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Decoder_3to8_tb Simulate > Start Simulation → work → Decoder_3to8_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Decoder_3to8_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Decoder_3to8.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Decoder_3to8_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
