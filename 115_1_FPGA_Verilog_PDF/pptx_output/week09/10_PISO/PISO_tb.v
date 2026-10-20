`timescale 1ns/1ps

// =====================================================================
// PISO_tb：並進串出移位暫存器測試平台
//   Data_In = 1101（講義第 32 頁）：載入一次後，SO 依序送出 1、1、0、1
// =====================================================================
module PISO_tb;
    reg        Clock, Clear, Load;
    reg  [3:0] Data_In;
    wire       SO;

    initial Clock = 1'b0;
    always #5 Clock = ~Clock;           // 週期 10ns，正緣在 5、15、25 ...

    PISO_Shift_Register uut (.Clock(Clock), .Clear(Clear), .Load(Load), .Data_In(Data_In), .SO(SO));

    always @(negedge Clock)
        $display("t=%0d  Clear=%b Load=%b Data_In=%b  ->  Reg4=%b  SO=%b",
                 $time, Clear, Load, Data_In, uut.Reg4, SO);

    initial begin
            Clear = 1; Load = 0; Data_In = 4'b1101;
        #10 Clear = 0; Load = 1;                // 載入 1101
        #10 Load  = 0;                          // 開始串出
        #60 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Clear=1 Load=0 Data_In=1101  ->  Reg4=xxxx  SO=x
//   t=10  Clear=0 Load=1 Data_In=1101  ->  Reg4=0000  SO=x
//   t=20  Clear=0 Load=0 Data_In=1101  ->  Reg4=1101  SO=x
//   t=30  Clear=0 Load=0 Data_In=1101  ->  Reg4=1010  SO=1
//   t=40  Clear=0 Load=0 Data_In=1101  ->  Reg4=0100  SO=1
//   t=50  Clear=0 Load=0 Data_In=1101  ->  Reg4=1000  SO=0
//   t=60  Clear=0 Load=0 Data_In=1101  ->  Reg4=0000  SO=1
//   t=70  Clear=0 Load=0 Data_In=1101  ->  Reg4=0000  SO=0
//   ** Note: $stop    : PISO_tb.v(25)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module PISO_tb at PISO_tb.v line 25
//
// 觀察重點：t=15 的正緣載入 1101，之後每個正緣左移一格；SO 依序送出 1、1、0、1（講義第 32 頁），送完後 Reg4 補進來的都是 0，所以 SO 之後一直是 0


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog PISO_Shift_Register.v PISO_tb.v     Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.PISO_tb         Simulate > Start Simulation → work → PISO_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 PISO_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 PISO_Shift_Register.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, PISO_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
