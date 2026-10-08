`timescale 1ns/1ps

// =====================================================================
// Func_AS_inc_tb：`include 版本的測試平台
//   測試內容和 Func_AS_tb 完全相同，輸出也應該一模一樣
// =====================================================================
module Func_AS_inc_tb;
    reg  [3:0] a, b;
    reg        Add, Sub, Inc, Switch;
    wire [3:0] c;

    Func_AS_inc uut (.a(a), .b(b), .Add(Add), .Sub(Sub), .Inc(Inc), .Switch(Switch), .c(c));

    initial begin
        $monitor("t=%0d  a=%0d b=%0d  Add=%b Sub=%b Inc=%b Switch=%b  ->  c=%b (%0d)",
                 $time, a, b, Add, Sub, Inc, Switch, c, c);
        a = 4'b1111; b = 4'b0011;
        Add = 1; Sub = 0; Inc = 0; Switch = 0; #10;   // a + b = 18 → 溢位剩 2
        Add = 0; Sub = 1; Inc = 0; Switch = 1; #10;   // a - b = 12
        Add = 0; Sub = 1; Inc = 0; Switch = 0; #10;   // b - a = -12 → 2 的補數 = 4
        Add = 0; Sub = 0; Inc = 1; Switch = 1; #10;   // a + 1 = 16 → 0
        Add = 0; Sub = 0; Inc = 1; Switch = 0; #10;   // b + 1 = 4
        Add = 0; Sub = 0; Inc = 0; Switch = 1; #10;   // a - 1 = 14
        Add = 0; Sub = 0; Inc = 0; Switch = 0; #10;   // b - 1 = 2
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  a=15 b=3  Add=1 Sub=0 Inc=0 Switch=0  ->  c=0010 (2)
//   t=10  a=15 b=3  Add=0 Sub=1 Inc=0 Switch=1  ->  c=1100 (12)
//   t=20  a=15 b=3  Add=0 Sub=1 Inc=0 Switch=0  ->  c=0100 (4)
//   t=30  a=15 b=3  Add=0 Sub=0 Inc=1 Switch=1  ->  c=0000 (0)
//   t=40  a=15 b=3  Add=0 Sub=0 Inc=1 Switch=0  ->  c=0100 (4)
//   t=50  a=15 b=3  Add=0 Sub=0 Inc=0 Switch=1  ->  c=1110 (14)
//   t=60  a=15 b=3  Add=0 Sub=0 Inc=0 Switch=0  ->  c=0010 (2)
//   ** Note: $stop    : Func_AS_inc_tb.v(25)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Func_AS_inc_tb at Func_AS_inc_tb.v line 25
//
// 觀察重點：每一行都和 Func_AS_tb（函數直接寫在模組裡的版本）完全相同：`include 只是把檔案內容貼進來，電路沒有任何不同


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run_inc.do
//   方法 B（逐行輸入，和 run_inc.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Func_AS_inc.v Func_AS_inc_tb.v      Compile > Compile...（只選這兩個 .v，不要選 .vh）
//     2. 載入模擬   vsim -voptargs=+acc work.Func_AS_inc_tb  Simulate > Start Simulation → work → Func_AS_inc_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Func_AS_inc_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 貼上 Func_AS_inc.v
//   另外新增一個檔案分頁，命名為 Sub_Inc_Dec.vh，貼上函數檔的內容（檔名要和 `include 裡寫的一樣）
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Func_AS_inc_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
