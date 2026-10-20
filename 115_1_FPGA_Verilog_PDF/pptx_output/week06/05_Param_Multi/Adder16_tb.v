`timescale 1ns/1ps

// =====================================================================
// Adder16_tb：講義第 13 頁的 Adder16_test.v（講義的 testbench 模組名稱是 t）
//   m      ：Adder16，裡面用 #(our_size1, our_size2) 傳 2 個值給 Adder 的 2 個參數（多對多）
//   u_less ：直接用 Adder #(4)，只傳 1 個值給 2 個參數（少對多）→ size1 = 4，size2 保留預設 2
// =====================================================================
module Adder16_tb;
    parameter our_size1 = 8;        // 定義為 8 個位元
    parameter our_size2 = 16;
    reg  [our_size1-1:0] A, B;
    reg                  Carry_In;
    wire [our_size1-1:0] Sum;
    wire                 Carry_Out;
    wire [3:0]           Sum4;
    wire                 Carry_Out4;

    Adder16 m
        (.A(A), .B(B), .Carry_In(Carry_In), .Sum(Sum), .Carry_Out(Carry_Out));

    Adder #(4) u_less                               // 少對多：只給第 1 個參數
        (.A(A[3:0]), .B(B[3:0]), .Carry_In(Carry_In), .Sum(Sum4), .Carry_Out(Carry_Out4));
    // 多對少（給的值比參數多）不可以，例如 Adder #(4, 8, 16) 會在載入模擬時出錯

    initial begin
        $display("m.My_Adder16 : size1 = %0d, size2 = %0d", m.My_Adder16.size1, m.My_Adder16.size2);
        $display("u_less       : size1 = %0d, size2 = %0d", u_less.size1, u_less.size2);
        $monitor("t=%0d  A=%b B=%b Cin=%b  ->  8-bit: Cout=%b Sum=%b(%0d)   4-bit: Cout=%b Sum=%b",
                 $time, A, B, Carry_In, Carry_Out, Sum, Sum, Carry_Out4, Sum4);
        A = 8'b0000_0111; B = 8'b0000_0110; Carry_In = 1; #10;   // 7 + 6 + 1 = 14
        A = 8'b0000_0011; B = 8'b0000_1100; Carry_In = 0; #10;   // 3 + 12 + 0 = 15
        A = 8'b0000_0001; B = 8'b0000_1111; Carry_In = 1; #10;   // 1 + 15 + 1 = 17
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   m.My_Adder16 : size1 = 8, size2 = 16
//   u_less       : size1 = 4, size2 = 2
//   t=0  A=00000111 B=00000110 Cin=1  ->  8-bit: Cout=0 Sum=00001110(14)   4-bit: Cout=0 Sum=1110
//   t=10  A=00000011 B=00001100 Cin=0  ->  8-bit: Cout=0 Sum=00001111(15)   4-bit: Cout=0 Sum=1111
//   t=20  A=00000001 B=00001111 Cin=1  ->  8-bit: Cout=0 Sum=00010001(17)   4-bit: Cout=1 Sum=0001
//   ** Note: $stop    : Adder16_tb.v(33)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Adder16_tb at Adder16_tb.v line 33
//
// 觀察重點：m 的兩個參數都被改寫（size1=8、size2=16），u_less 只給一個值，所以只有 size1 變成 4、size2 還是預設的 2；8 位元結果和講義第 14 頁相同


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
