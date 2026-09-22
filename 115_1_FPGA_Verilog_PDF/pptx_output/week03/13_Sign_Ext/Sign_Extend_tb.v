`timescale 1ns/1ps

module Sign_Extend_tb;
    reg         SignExtend;
    reg  [7:0]  Word;
    wire [15:0] Double;
    wire signed [15:0] Double_s = Double;   // 同一組位元，用「有號數」的方式解讀

    Sign_Extend uut (.SignExtend(SignExtend), .Word(Word), .Double(Double));

    initial begin
        $monitor("t=%0d  SignExtend=%b Word=%b  ->  Double=%b  (signed %0d)",
                 $time, SignExtend, Word, Double, Double_s);
        SignExtend = 1; Word = 8'b1100_0011; #10;   // 講義第 72 頁：負數 → 高位補 1
        SignExtend = 0; Word = 8'b1100_0011; #10;   // 講義第 72 頁：補 0
        SignExtend = 1; Word = 8'b0000_1111; #10;   // 正數：補 1 或 0 都是補 0
        SignExtend = 1; Word = 8'b1000_1111; #10;
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  SignExtend=1 Word=11000011  ->  Double=1111111111000011  (signed -61)
//   t=10  SignExtend=0 Word=11000011  ->  Double=0000000011000011  (signed 195)
//   t=20  SignExtend=1 Word=00001111  ->  Double=0000000000001111  (signed 15)
//   t=30  SignExtend=1 Word=10001111  ->  Double=1111111110001111  (signed -113)
//   ** Note: $stop    : Sign_Extend_tb.v(18)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Sign_Extend_tb at Sign_Extend_tb.v line 18


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Sign_Extend.v Sign_Extend_tb.v      Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Sign_Extend_tb  Simulate > Start Simulation → work → Sign_Extend_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Sign_Extend_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Sign_Extend.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Sign_Extend_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
