`timescale 1ns/1ps

// =====================================================================
// Reg4_tb：同一組輸入同時餵給 RAS_NRPC（非同步重置）和 RS_NRPC（同步重置）
//   Reg_In 依序 0001、0011、0010、0100、1101、1010、0111（講義第 16、18 頁波形上的值）
//   Reset 在兩個正緣中間變成 0，比較兩顆清 0 的時間
// =====================================================================
module Reg4_tb;
    reg        Reset, Clock;
    reg  [3:0] Reg_In;
    wire [3:0] Reg_Out1, Reg_Out3;

    initial Clock = 1'b0;
    always #5 Clock = ~Clock;           // 週期 10ns，正緣在 5、15、25 ...

    RAS_NRPC u_async (.Reset(Reset), .Clock(Clock), .Reg_In(Reg_In), .Reg_Out1(Reg_Out1));
    RS_NRPC  u_sync  (.Reset(Reset), .Clock(Clock), .Reg_In(Reg_In), .Reg_Out3(Reg_Out3));

    initial begin
        $monitor("t=%0d  Clock=%b Reset=%b Reg_In=%b  ->  async Reg_Out1=%b   sync Reg_Out3=%b",
                 $time, Clock, Reset, Reg_In, Reg_Out1, Reg_Out3);
            Reset = 1; Reg_In = 4'b0001;
        #10 Reg_In = 4'b0011;               // t=10（時脈中間換資料）
        #10 Reg_In = 4'b0010;               // t=20
        #2  Reset  = 0;                     // t=22：async 立刻清 0，sync 等 t=25
        #8  Reg_In = 4'b0100;               // t=30
        #2  Reset  = 1;                     // t=32
        #8  Reg_In = 4'b1101;               // t=40
        #10 Reg_In = 4'b1010;               // t=50
        #10 Reg_In = 4'b0111;               // t=60
        #10 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Clock=0 Reset=1 Reg_In=0001  ->  async Reg_Out1=xxxx   sync Reg_Out3=xxxx
//   t=5  Clock=1 Reset=1 Reg_In=0001  ->  async Reg_Out1=0001   sync Reg_Out3=0001
//   t=10  Clock=0 Reset=1 Reg_In=0011  ->  async Reg_Out1=0001   sync Reg_Out3=0001
//   t=15  Clock=1 Reset=1 Reg_In=0011  ->  async Reg_Out1=0011   sync Reg_Out3=0011
//   t=20  Clock=0 Reset=1 Reg_In=0010  ->  async Reg_Out1=0011   sync Reg_Out3=0011
//   t=22  Clock=0 Reset=0 Reg_In=0010  ->  async Reg_Out1=0000   sync Reg_Out3=0011
//   t=25  Clock=1 Reset=0 Reg_In=0010  ->  async Reg_Out1=0000   sync Reg_Out3=0000
//   t=30  Clock=0 Reset=0 Reg_In=0100  ->  async Reg_Out1=0000   sync Reg_Out3=0000
//   t=32  Clock=0 Reset=1 Reg_In=0100  ->  async Reg_Out1=0000   sync Reg_Out3=0000
//   t=35  Clock=1 Reset=1 Reg_In=0100  ->  async Reg_Out1=0100   sync Reg_Out3=0100
//   t=40  Clock=0 Reset=1 Reg_In=1101  ->  async Reg_Out1=0100   sync Reg_Out3=0100
//   t=45  Clock=1 Reset=1 Reg_In=1101  ->  async Reg_Out1=1101   sync Reg_Out3=1101
//   t=50  Clock=0 Reset=1 Reg_In=1010  ->  async Reg_Out1=1101   sync Reg_Out3=1101
//   t=55  Clock=1 Reset=1 Reg_In=1010  ->  async Reg_Out1=1010   sync Reg_Out3=1010
//   t=60  Clock=0 Reset=1 Reg_In=0111  ->  async Reg_Out1=1010   sync Reg_Out3=1010
//   t=65  Clock=1 Reset=1 Reg_In=0111  ->  async Reg_Out1=0111   sync Reg_Out3=0111
//   ** Note: $stop    : Reg4_tb.v(31)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Reg4_tb at Reg4_tb.v line 31
//
// 觀察重點：兩顆在 Reset=1 時都是正緣才載入 Reg_In；t=22 Reset 變 0：非同步的 Reg_Out1 立刻清 0，同步的 Reg_Out3 要等 t=25 的正緣；Reset=0 期間（t=22~32）兩顆都維持 0


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog RAS_NRPC.v RS_NRPC.v Reg4_tb.v      Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Reg4_tb         Simulate > Start Simulation → work → Reg4_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Reg4_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 RAS_NRPC.v、RS_NRPC.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Reg4_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
