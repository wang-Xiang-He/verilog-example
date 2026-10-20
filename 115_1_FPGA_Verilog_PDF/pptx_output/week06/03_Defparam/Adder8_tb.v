`timescale 1ns/1ps

// =====================================================================
// Adder8_tb：8 位元加法器測試平台
//   前 2 組 = 講義第 8 頁波形的數值，第 3 組 = 波形最右邊游標處的數值
// =====================================================================
module Adder8_tb;
    reg  [7:0] A, B;
    reg        Carry_In;
    wire [7:0] Sum;
    wire       Carry_Out;

    Adder8 uut (.A(A), .B(B), .Carry_In(Carry_In), .Sum(Sum), .Carry_Out(Carry_Out));

    initial begin
        // 階層式名稱 uut.My_Adder8.size：看 defparam 改寫後的值
        $display("uut.our_size = %0d,  uut.My_Adder8.size = %0d", uut.our_size, uut.My_Adder8.size);
        $monitor("t=%0d  A=%b(%0d) B=%b(%0d) Cin=%b  ->  Cout=%b Sum=%b(%0d)",
                 $time, A, A, B, B, Carry_In, Carry_Out, Sum, Sum);
        A = 8'b0000_0111; B = 8'b0000_0110; Carry_In = 1; #10;   // 7 + 6 + 1 = 14
        A = 8'b0000_0011; B = 8'b0000_1100; Carry_In = 0; #10;   // 3 + 12 + 0 = 15
        A = 8'b0000_0001; B = 8'b0000_1111; Carry_In = 1; #10;   // 1 + 15 + 1 = 17
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   uut.our_size = 8,  uut.My_Adder8.size = 8
//   t=0  A=00000111(7) B=00000110(6) Cin=1  ->  Cout=0 Sum=00001110(14)
//   t=10  A=00000011(3) B=00001100(12) Cin=0  ->  Cout=0 Sum=00001111(15)
//   t=20  A=00000001(1) B=00001111(15) Cin=1  ->  Cout=0 Sum=00010001(17)
//   ** Note: $stop    : Adder8_tb.v(23)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Adder8_tb at Adder8_tb.v line 23
//
// 觀察重點：My_Adder8.size 由預設的 1 被 defparam 改成 8，所以能做 8 位元加法；結果和講義第 8 頁的 00001110、00001111 相同


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Adder8.v Adder8_tb.v                Compile > Compile...（只選這兩個，不要選 Scalable.v）
//     2. 載入模擬   vsim -voptargs=+acc work.Adder8_tb       Simulate > Start Simulation → work → Adder8_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Adder8_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Adder8.v
//   另外新增一個檔案分頁，命名為 Scalable.v，貼上 Scalable.v 的內容（檔名要和 `include 裡寫的一樣）
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Adder8_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
