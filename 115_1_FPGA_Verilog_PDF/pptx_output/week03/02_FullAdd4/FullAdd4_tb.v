`timescale 1ns/1ps

// =====================================================================
// FullAdd4_tb：4 位元漣波進位加法器的測試平台
// =====================================================================
module FullAdd4_tb;
    reg  [3:0] a, b;
    reg        Carry_In;
    wire [3:0] Sum;
    wire       Carry_Out;
    wire [4:0] total = {Carry_Out, Sum};   // 5 位元完整結果，方便用十進位對照

    FullAdd4 uut (
        .a(a), .b(b), .Carry_In(Carry_In),
        .Sum(Sum), .Carry_Out(Carry_Out)
    );

    initial begin
        $monitor("t=%0d  a=%b b=%b Cin=%b  ->  Cout=%b Sum=%b  (%0d + %0d + %0d = %0d)",
                 $time, a, b, Carry_In, Carry_Out, Sum, a, b, Carry_In, total);

        // 前 4 組 = 講義第 8 頁模擬的 Add1~Add4
        a = 4'b0000; b = 4'b0000; Carry_In = 0; #10;   // Add1
        a = 4'b0000; b = 4'b0000; Carry_In = 1; #10;   // Add2
        a = 4'b0000; b = 4'b1111; Carry_In = 0; #10;   // Add3
        a = 4'b0000; b = 4'b1111; Carry_In = 1; #10;   // Add4：進位一路傳到最高位
        // 額外 2 組
        a = 4'b0101; b = 4'b0011; Carry_In = 0; #10;   // 5 + 3 = 8
        a = 4'b1111; b = 4'b1111; Carry_In = 1; #10;   // 最大值 15 + 15 + 1 = 31

        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  a=0000 b=0000 Cin=0  ->  Cout=0 Sum=0000  (0 + 0 + 0 = 0)
//   t=10  a=0000 b=0000 Cin=1  ->  Cout=0 Sum=0001  (0 + 0 + 1 = 1)
//   t=20  a=0000 b=1111 Cin=0  ->  Cout=0 Sum=1111  (0 + 15 + 0 = 15)
//   t=30  a=0000 b=1111 Cin=1  ->  Cout=1 Sum=0000  (0 + 15 + 1 = 16)
//   t=40  a=0101 b=0011 Cin=0  ->  Cout=0 Sum=1000  (5 + 3 + 0 = 8)
//   t=50  a=1111 b=1111 Cin=1  ->  Cout=1 Sum=1111  (15 + 15 + 1 = 31)
//   ** Note: $stop    : FullAdd4_tb.v(31)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module FullAdd4_tb at FullAdd4_tb.v line 31
//
// 觀察重點：波形中向量訊號可在 Wave 視窗選取後按右鍵 > Radix > Unsigned 改成十進位；想看內部進位，在 sim 視窗點 uut 就能加入 Carry_Out1~3


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog FullAdd.v FullAdd4.v FullAdd4_tb.v  Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.FullAdd4_tb     Simulate > Start Simulation → work → FullAdd4_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 FullAdd4_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 FullAdd.v、FullAdd4.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, FullAdd4_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
