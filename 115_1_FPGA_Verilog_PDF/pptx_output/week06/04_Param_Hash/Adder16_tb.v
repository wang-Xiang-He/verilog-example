`timescale 1ns/1ps

// =====================================================================
// Adder16_tb：16 位元加法器測試平台
//   uut16：用 Adder16 的預設 our_size = 16（數值 = 講義第 10 頁波形）
//   uut4 ：在 testbench 再用 #(.our_size(4)) 依名稱改成 4 位元 → 參數可以一層一層往下傳
// =====================================================================
module Adder16_tb;
    reg  [15:0] A, B;
    reg         Carry_In;
    wire [15:0] Sum;
    wire        Carry_Out;
    wire [3:0]  Sum4;
    wire        Carry_Out4;

    Adder16                 uut16 (.A(A),      .B(B),      .Carry_In(Carry_In), .Sum(Sum),  .Carry_Out(Carry_Out));
    Adder16 #(.our_size(4)) uut4  (.A(A[3:0]), .B(B[3:0]), .Carry_In(Carry_In), .Sum(Sum4), .Carry_Out(Carry_Out4));

    initial begin
        $display("uut16.My_Adder16.size = %0d,  uut4.My_Adder16.size = %0d",
                 uut16.My_Adder16.size, uut4.My_Adder16.size);
        $monitor("t=%0d  A=%0d B=%0d Cin=%b  ->  16-bit: Cout=%b Sum=%b   4-bit: Cout=%b Sum=%b",
                 $time, A, B, Carry_In, Carry_Out, Sum, Carry_Out4, Sum4);
        A = 16'd7; B = 16'd6;  Carry_In = 1; #10;    //  7 +  6 + 1 = 14
        A = 16'd3; B = 16'd12; Carry_In = 0; #10;    //  3 + 12 + 0 = 15
        A = 16'd1; B = 16'd15; Carry_In = 1; #10;    //  1 + 15 + 1 = 17 → 4 位元放不下，進位 1
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   uut16.My_Adder16.size = 16,  uut4.My_Adder16.size = 4
//   t=0  A=7 B=6 Cin=1  ->  16-bit: Cout=0 Sum=0000000000001110   4-bit: Cout=0 Sum=1110
//   t=10  A=3 B=12 Cin=0  ->  16-bit: Cout=0 Sum=0000000000001111   4-bit: Cout=0 Sum=1111
//   t=20  A=1 B=15 Cin=1  ->  16-bit: Cout=0 Sum=0000000000010001   4-bit: Cout=1 Sum=0001
//   ** Note: $stop    : Adder16_tb.v(27)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Adder16_tb at Adder16_tb.v line 27
//
// 觀察重點：16 位元的結果和講義第 10 頁相同；同一個 Adder16 用 #(.our_size(4)) 就變成 4 位元，17 放不下 → Sum4=0001、Cout4=1


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Adder16.v Adder16_tb.v              Compile > Compile...（只選這兩個，不要選 Scalable.v）
//     2. 載入模擬   vsim -voptargs=+acc work.Adder16_tb      Simulate > Start Simulation → work → Adder16_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Adder16_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Adder16.v
//   另外新增一個檔案分頁，命名為 Scalable.v，貼上 Scalable.v 的內容（檔名要和 `include 裡寫的一樣）
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Adder16_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
