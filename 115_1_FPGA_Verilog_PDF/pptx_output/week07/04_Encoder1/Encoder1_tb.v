`timescale 1ns/1ps

// =====================================================================
// Encoder1_tb：優先權編碼器測試平台
//   前 10 組 = 講義第 17 頁波形：00000000、00000001、00000010 ... 10000000、00000000
//   再加上講義第 16 頁問的 0001_0001，以及第 17 頁畫面上的 1010_1010
// =====================================================================
module Encoder1_tb;
    reg  [7:0] In;
    wire [2:0] Out;
    wire       None_ON;
    integer    k;

    Encoder1 uut (.In(In), .Out(Out), .None_ON(None_ON));

    initial begin
        $monitor("t=%0d  In=%b  ->  Out=%b (%0d)  None_ON=%b", $time, In, Out, Out, None_ON);
        In = 8'b0000_0000; #10;
        for (k = 0; k < 8; k = k + 1) begin
            In = 8'b1 << k; #10;            // 一次只有一個位元是 1
        end
        In = 8'b0000_0000; #10;
        In = 8'b0001_0001; #10;             // 11H：In[4] 和 In[0] 都是 1 → 取高的 In[4]
        In = 8'b1010_1010; #10;             // 最高的 1 在 In[7]
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  In=00000000  ->  Out=000 (0)  None_ON=1
//   t=10  In=00000001  ->  Out=000 (0)  None_ON=0
//   t=20  In=00000010  ->  Out=001 (1)  None_ON=0
//   t=30  In=00000100  ->  Out=010 (2)  None_ON=0
//   t=40  In=00001000  ->  Out=011 (3)  None_ON=0
//   t=50  In=00010000  ->  Out=100 (4)  None_ON=0
//   t=60  In=00100000  ->  Out=101 (5)  None_ON=0
//   t=70  In=01000000  ->  Out=110 (6)  None_ON=0
//   t=80  In=10000000  ->  Out=111 (7)  None_ON=0
//   t=90  In=00000000  ->  Out=000 (0)  None_ON=1
//   t=100  In=00010001  ->  Out=100 (4)  None_ON=0
//   t=110  In=10101010  ->  Out=111 (7)  None_ON=0
//   ** Note: $stop    : Encoder1_tb.v(25)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Encoder1_tb at Encoder1_tb.v line 25
//
// 觀察重點：In 只有一個 1 時 Out = 那個 1 的位置；In 全為 0 時 None_ON = 1；0001_0001 得到 4（取最高位），1010_1010 得到 7（講義第 17 頁畫面上的 111）


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Encoder1.v Encoder1_tb.v            Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Encoder1_tb     Simulate > Start Simulation → work → Encoder1_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Encoder1_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Encoder1.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Encoder1_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
