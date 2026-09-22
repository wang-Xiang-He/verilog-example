`timescale 1ns/1ps

// =====================================================================
// FullAdd_tb：1 位元全加器的測試平台（testbench）
// =====================================================================
module FullAdd_tb;                 // testbench 沒有輸入輸出埠
    reg  a, b, Carry_In;           // 要餵給電路的訊號 → reg（在 initial 裡被賦值）
    wire Sum, Carry_Out;           // 從電路接出來的訊號 → wire
    integer i;

    // 實例化待測電路（UUT = Unit Under Test），用「依名稱」對應埠
    FullAdd uut (
        .a(a), .b(b), .Carry_In(Carry_In),
        .Sum(Sum), .Carry_Out(Carry_Out)
    );

    initial begin
        // 訊號一變就印出一行，輸出在 Transcript 視窗
        // 時間用 %0d 印（單位 ns）；若用 %0t 會依 1ps 精度印成 10000 這種數字
        $monitor("t=%0d  a=%b b=%b Cin=%b  ->  Cout=%b Sum=%b",
                 $time, a, b, Carry_In, Carry_Out, Sum);

        for (i = 0; i < 8; i = i + 1) begin
            {a, b, Carry_In} = i;  // 把 0~7 拆成 3 個位元
            #10;                   // 每組輸入維持 10ns
        end

        $stop;                     // 暫停模擬，波形保留
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  a=0 b=0 Cin=0  ->  Cout=0 Sum=0
//   t=10  a=0 b=0 Cin=1  ->  Cout=0 Sum=1
//   t=20  a=0 b=1 Cin=0  ->  Cout=0 Sum=1
//   t=30  a=0 b=1 Cin=1  ->  Cout=1 Sum=0
//   t=40  a=1 b=0 Cin=0  ->  Cout=0 Sum=1
//   t=50  a=1 b=0 Cin=1  ->  Cout=1 Sum=0
//   t=60  a=1 b=1 Cin=0  ->  Cout=1 Sum=0
//   t=70  a=1 b=1 Cin=1  ->  Cout=1 Sum=1
//   ** Note: $stop    : FullAdd_tb.v(28)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module FullAdd_tb at FullAdd_tb.v line 28


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog FullAdd.v FullAdd_tb.v              Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.FullAdd_tb      Simulate > Start Simulation → work → FullAdd_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 FullAdd_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 FullAdd.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, FullAdd_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
