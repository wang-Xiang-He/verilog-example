`timescale 1ns/1ps

module For_XOR_tb;
    reg  [3:0] a, b;
    wire [3:0] Out;
    wire       c;

    For_XOR uut (.a(a), .b(b), .Out(Out), .c(c));

    initial begin
        $monitor("t=%0d  a=%b b=%b  ->  Out=a^b=%b  c=%b", $time, a, b, Out, c);
        a = 4'b1100; b = 4'b1010; #10;   // 每一位 a|b 都是 1 → c = 1
        a = 4'b1100; b = 4'b0010; #10;   // 第 0 位 a|b = 0   → c = 0
        a = 4'b1111; b = 4'b1111; #10;
        a = 4'b0000; b = 4'b1111; #10;
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  a=1100 b=1010  ->  Out=a^b=0110  c=0
//   t=10  a=1100 b=0010  ->  Out=a^b=1110  c=0
//   t=20  a=1111 b=1111  ->  Out=a^b=0000  c=1
//   t=30  a=0000 b=1111  ->  Out=a^b=1111  c=1
//   ** Note: $stop    : For_XOR_tb.v(16)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module For_XOR_tb at For_XOR_tb.v line 16
//
// 觀察重點：Out 是逐位元 XOR；c 只有在每一位 a|b 都是 1 時才是 1


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog For_XOR.v For_XOR_tb.v              Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.For_XOR_tb      Simulate > Start Simulation → work → For_XOR_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 For_XOR_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 For_XOR.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, For_XOR_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
