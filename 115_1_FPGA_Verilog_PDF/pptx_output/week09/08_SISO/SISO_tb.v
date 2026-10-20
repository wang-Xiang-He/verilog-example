`timescale 1ns/1ps

// =====================================================================
// SISO_tb：兩種寫法的串進串出移位暫存器一起測
//   講義第 21、22 頁：「請改寫程式把 Reg4 的值顯示出來」
//     講義的方法是把 Reg4 改成輸出埠；這裡不改模組，直接用階層式名稱 u1.Reg4 印出來（只能用在模擬）
//   SI 依序送入 1 1 0 1，之後都送 0 → 看 1101 從 SO 一個一個出來
// =====================================================================
module SISO_tb;
    reg  Clock, Clear, SI;
    wire SO1, SO2;

    initial Clock = 1'b0;
    always #5 Clock = ~Clock;           // 週期 10ns，正緣在 5、15、25 ...

    SISO_Shift_Register     u1 (.Clock(Clock), .Clear(Clear), .SI(SI), .SO(SO1));
    SISO_Shift_Register_For u2 (.Clock(Clock), .Clear(Clear), .SI(SI), .SO(SO2));

    always @(negedge Clock)             // 在負緣印出（正緣的變化已經穩定）
        $display("t=%0d  Clear=%b SI=%b  ->  Reg4=%b SO=%b   |  for: Reg4=%b SO=%b",
                 $time, Clear, SI, u1.Reg4, SO1, u2.Reg4, SO2);

    initial begin
            Clear = 1; SI = 0;          // 第 1 個正緣清除（SO 還沒被設定 → x）
        #10 Clear = 0; SI = 1;          // t=10 起每 10ns 換一個 SI
        #10 SI = 1;
        #10 SI = 0;
        #10 SI = 1;
        #10 SI = 0;
        #60 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Clear=1 SI=0  ->  Reg4=xxxx SO=x   |  for: Reg4=xxxx SO=x
//   t=10  Clear=0 SI=1  ->  Reg4=0000 SO=x   |  for: Reg4=0000 SO=x
//   t=20  Clear=0 SI=1  ->  Reg4=0001 SO=0   |  for: Reg4=0001 SO=0
//   t=30  Clear=0 SI=0  ->  Reg4=0011 SO=0   |  for: Reg4=0011 SO=0
//   t=40  Clear=0 SI=1  ->  Reg4=0110 SO=0   |  for: Reg4=0110 SO=0
//   t=50  Clear=0 SI=0  ->  Reg4=1101 SO=0   |  for: Reg4=1101 SO=0
//   t=60  Clear=0 SI=0  ->  Reg4=1010 SO=1   |  for: Reg4=1010 SO=1
//   t=70  Clear=0 SI=0  ->  Reg4=0100 SO=1   |  for: Reg4=0100 SO=1
//   t=80  Clear=0 SI=0  ->  Reg4=1000 SO=0   |  for: Reg4=1000 SO=0
//   t=90  Clear=0 SI=0  ->  Reg4=0000 SO=1   |  for: Reg4=0000 SO=1
//   t=100  Clear=0 SI=0  ->  Reg4=0000 SO=0   |  for: Reg4=0000 SO=0
//   ** Note: $stop    : SISO_tb.v(30)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module SISO_tb at SISO_tb.v line 30
//
// 觀察重點：SI 依序送入 1、1、0、1，Reg4 每個時脈左移一格；第一個 1 在 t=15 的正緣進入 Reg4[0]，4 個時脈後（t=55）才從 SO 出來（講義第 21 頁的 4 clocks），SO 依序是 1、1、0、1；兩種寫法每一行都一樣


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog SISO_Shift_Register.v SISO_Shift_Register_For.v SISO_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.SISO_tb         Simulate > Start Simulation → work → SISO_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 SISO_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 SISO_Shift_Register.v、SISO_Shift_Register_For.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, SISO_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
