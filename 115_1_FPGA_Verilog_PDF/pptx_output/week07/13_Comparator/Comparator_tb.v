`timescale 1ns/1ps

// =====================================================================
// Comparator_tb：同步比較器測試平台
//   三組數值 = 講義第 60 頁波形：(11111111, 00000001)、(00111111, 00111111)、(00000011, 10101010)
//   A、B 在時脈中間（負緣附近）改變，看結果要等到哪一個正緣才出來
// =====================================================================
module Comparator_tb;
    reg  [7:0] A, B;
    reg        CLK;
    wire       AGTB, AEQB, ALTB;

    Comparator uut (.A(A), .B(B), .CLK(CLK), .AGTB(AGTB), .AEQB(AEQB), .ALTB(ALTB));

    initial CLK = 1'b0;
    always #10 CLK = ~CLK;          // 週期 20ns，正緣在 10、30、50 ...

    initial begin
        $monitor("t=%0d  CLK=%b  A=%b(%0d) B=%b(%0d)  ->  AGTB=%b AEQB=%b ALTB=%b",
                 $time, CLK, A, A, B, B, AGTB, AEQB, ALTB);
        #5  A = 8'b1111_1111; B = 8'b0000_0001;   // A > B
        #40 A = 8'b0011_1111; B = 8'b0011_1111;   // A = B
        #40 A = 8'b0000_0011; B = 8'b1010_1010;   // A < B
        #40 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  CLK=0  A=xxxxxxxx(x) B=xxxxxxxx(x)  ->  AGTB=x AEQB=x ALTB=x
//   t=5  CLK=0  A=11111111(255) B=00000001(1)  ->  AGTB=x AEQB=x ALTB=x
//   t=10  CLK=1  A=11111111(255) B=00000001(1)  ->  AGTB=1 AEQB=0 ALTB=0
//   t=20  CLK=0  A=11111111(255) B=00000001(1)  ->  AGTB=1 AEQB=0 ALTB=0
//   t=30  CLK=1  A=11111111(255) B=00000001(1)  ->  AGTB=1 AEQB=0 ALTB=0
//   t=40  CLK=0  A=11111111(255) B=00000001(1)  ->  AGTB=1 AEQB=0 ALTB=0
//   t=45  CLK=0  A=00111111(63) B=00111111(63)  ->  AGTB=1 AEQB=0 ALTB=0
//   t=50  CLK=1  A=00111111(63) B=00111111(63)  ->  AGTB=0 AEQB=1 ALTB=0
//   t=60  CLK=0  A=00111111(63) B=00111111(63)  ->  AGTB=0 AEQB=1 ALTB=0
//   t=70  CLK=1  A=00111111(63) B=00111111(63)  ->  AGTB=0 AEQB=1 ALTB=0
//   t=80  CLK=0  A=00111111(63) B=00111111(63)  ->  AGTB=0 AEQB=1 ALTB=0
//   t=85  CLK=0  A=00000011(3) B=10101010(170)  ->  AGTB=0 AEQB=1 ALTB=0
//   t=90  CLK=1  A=00000011(3) B=10101010(170)  ->  AGTB=0 AEQB=0 ALTB=1
//   t=100  CLK=0  A=00000011(3) B=10101010(170)  ->  AGTB=0 AEQB=0 ALTB=1
//   t=110  CLK=1  A=00000011(3) B=10101010(170)  ->  AGTB=0 AEQB=0 ALTB=1
//   t=120  CLK=0  A=00000011(3) B=10101010(170)  ->  AGTB=0 AEQB=0 ALTB=1
//   ** Note: $stop    : Comparator_tb.v(24)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Comparator_tb at Comparator_tb.v line 24
//
// 觀察重點：A、B 在 t=5、45、85 改變，但比較結果要到下一個正緣（t=10、50、90）才更新；t=0~10 還沒遇到正緣，結果是 x——這就是講義第 60 頁說的「不同步」


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
