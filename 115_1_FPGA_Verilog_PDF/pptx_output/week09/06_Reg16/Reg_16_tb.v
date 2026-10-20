`timescale 1ns/1ps

// =====================================================================
// Reg_16_tb：Reg_16 測試平台（數值和講義第 14 頁波形相同：0101、0010、0011）
// =====================================================================
module Reg_16_tb;
    reg         Clear;
    reg  [16:1] Reg_In;
    wire [16:1] Reg_Out;

    Reg_16 uut (.Clear(Clear), .Reg_In(Reg_In), .Reg_Out(Reg_Out));

    initial begin
        $monitor("t=%0d  Clear=%b  Reg_In=%b  ->  Reg_Out=%b", $time, Clear, Reg_In, Reg_Out);
            Clear = 0; Reg_In = 16'b0000_0000_0000_0101;    // 清為 0
        #10 Clear = 1;                                      // 載入 → 0101
        #10 Reg_In = 16'b0000_0000_0000_0010;               // Reg_In 一變，Reg_Out 立刻跟著變
        #10 Clear = 1'bx;                                   // Clear 不確定 → 保持
        #10 Reg_In = 16'b0000_0000_0000_0011;               // Reg_Out 不動
        #10 Clear = 1;                                      // 又跟著 Reg_In → 0011
        #10 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Clear=0  Reg_In=0000000000000101  ->  Reg_Out=0000000000000000
//   t=10  Clear=1  Reg_In=0000000000000101  ->  Reg_Out=0000000000000101
//   t=20  Clear=1  Reg_In=0000000000000010  ->  Reg_Out=0000000000000010
//   t=30  Clear=x  Reg_In=0000000000000010  ->  Reg_Out=0000000000000010
//   t=40  Clear=x  Reg_In=0000000000000011  ->  Reg_Out=0000000000000010
//   t=50  Clear=1  Reg_In=0000000000000011  ->  Reg_Out=0000000000000011
//   ** Note: $stop    : Reg_16_tb.v(21)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Reg_16_tb at Reg_16_tb.v line 21
//
// 觀察重點：Clear=1 時 Reg_Out 不等任何時脈就跟著 Reg_In 變（t=20），所以這個「暫存器」其實是組合邏輯；只有 Clear=x 時才保持舊值（t=40 Reg_In 改了 Reg_Out 也不動）


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Reg_16.v Reg_16_tb.v                Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Reg_16_tb       Simulate > Start Simulation → work → Reg_16_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Reg_16_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Reg_16.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Reg_16_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
