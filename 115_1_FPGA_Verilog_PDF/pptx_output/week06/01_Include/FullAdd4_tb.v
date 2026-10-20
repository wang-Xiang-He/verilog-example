`timescale 1ns/1ps

// =====================================================================
// FullAdd4_tb：4 位元加法器測試平台
//   6 組輸入 = 講義第 4 頁波形的數值
// =====================================================================
module FullAdd4_tb;
    reg  [3:0] a, b;
    reg        Carry_In;
    wire [3:0] Sum;
    wire       Carry_Out;
    wire [4:0] total = {Carry_Out, Sum};   // 5 位元完整結果，方便用十進位對照

    FullAdd4 uut (.a(a), .b(b), .Carry_In(Carry_In), .Sum(Sum), .Carry_Out(Carry_Out));

    initial begin
        $monitor("t=%0d  a=%b b=%b Cin=%b  ->  Cout=%b Sum=%b  (%0d + %0d + %0d = %0d)",
                 $time, a, b, Carry_In, Carry_Out, Sum, a, b, Carry_In, total);
        a = 4'b0000; b = 4'b1111; Carry_In = 1; #10;   // 0 + 15 + 1 = 16 → 1_0000
        a = 4'b0000; b = 4'b0111; Carry_In = 0; #10;   // 0 +  7 + 0 =  7
        a = 4'b0000; b = 4'b0111; Carry_In = 1; #10;   // 0 +  7 + 1 =  8
        a = 4'b1000; b = 4'b0111; Carry_In = 0; #10;   // 8 +  7 + 0 = 15
        a = 4'b1000; b = 4'b0111; Carry_In = 1; #10;   // 8 +  7 + 1 = 16 → 1_0000
        a = 4'b0111; b = 4'b0011; Carry_In = 0; #10;   // 7 +  3 + 0 = 10
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  a=0000 b=1111 Cin=1  ->  Cout=1 Sum=0000  (0 + 15 + 1 = 16)
//   t=10  a=0000 b=0111 Cin=0  ->  Cout=0 Sum=0111  (0 + 7 + 0 = 7)
//   t=20  a=0000 b=0111 Cin=1  ->  Cout=0 Sum=1000  (0 + 7 + 1 = 8)
//   t=30  a=1000 b=0111 Cin=0  ->  Cout=0 Sum=1111  (8 + 7 + 0 = 15)
//   t=40  a=1000 b=0111 Cin=1  ->  Cout=1 Sum=0000  (8 + 7 + 1 = 16)
//   t=50  a=0111 b=0011 Cin=0  ->  Cout=0 Sum=1010  (7 + 3 + 0 = 10)
//   ** Note: $stop    : FullAdd4_tb.v(25)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module FullAdd4_tb at FullAdd4_tb.v line 25
//
// 觀察重點：電路和 week03 的 02_FullAdd4 完全相同，差別只在 FullAdd 是用 `include 帶進來的；結果和講義第 4 頁波形的 0000、0111、1000、1111、0000、1010 相同


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog FullAdd4.v FullAdd4_tb.v            Compile > Compile...（只選這兩個，不要選 FullAdd.v）
//     2. 載入模擬   vsim -voptargs=+acc work.FullAdd4_tb     Simulate > Start Simulation → work → FullAdd4_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 FullAdd4_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 FullAdd4.v
//   另外新增一個檔案分頁，命名為 FullAdd.v，貼上 FullAdd.v 的內容（檔名要和 `include 裡寫的一樣，大小寫也要一樣）
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, FullAdd4_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
