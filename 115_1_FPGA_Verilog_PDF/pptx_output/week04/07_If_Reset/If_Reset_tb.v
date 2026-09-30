`timescale 1ns/1ps

// =====================================================================
// If_Reset_tb：兩個暫存器接同一條 Reset，觀察 High / Low Active 的差別
// =====================================================================
module If_Reset_tb;
    reg        Clock, Reset;
    reg  [3:0] In_Data;
    wire [3:0] Out_H, Out_L;

    Reg_RstHigh u_h (.Clock(Clock), .Reset(Reset), .In_Data(In_Data), .Out(Out_H));
    Reg_RstLow  u_l (.Clock(Clock), .Reset(Reset), .In_Data(In_Data), .Out(Out_L));

    // 時脈週期 10ns，正緣在 5, 15, 25 ...
    initial Clock = 0;
    always #5 Clock = ~Clock;

    // 輸入都在負緣（10, 20, 30 ...）改變，和正緣錯開
    initial begin
        $monitor("t=%0d  Clock=%b Reset=%b In_Data=%h  ->  Out_H=%h  Out_L=%h",
                 $time, Clock, Reset, In_Data, Out_H, Out_L);
        Reset = 1; In_Data = 4'hA;
        #10 In_Data = 4'h5;
        #10 Reset = 0;
        #10 In_Data = 4'h3;
        #10 Reset = 1;
        #10 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Clock=0 Reset=1 In_Data=a  ->  Out_H=x  Out_L=x
//   t=5  Clock=1 Reset=1 In_Data=a  ->  Out_H=0  Out_L=a
//   t=10  Clock=0 Reset=1 In_Data=5  ->  Out_H=0  Out_L=a
//   t=15  Clock=1 Reset=1 In_Data=5  ->  Out_H=0  Out_L=5
//   t=20  Clock=0 Reset=0 In_Data=5  ->  Out_H=0  Out_L=5
//   t=25  Clock=1 Reset=0 In_Data=5  ->  Out_H=5  Out_L=0
//   t=30  Clock=0 Reset=0 In_Data=3  ->  Out_H=5  Out_L=0
//   t=35  Clock=1 Reset=0 In_Data=3  ->  Out_H=3  Out_L=0
//   t=40  Clock=0 Reset=1 In_Data=3  ->  Out_H=3  Out_L=0
//   t=45  Clock=1 Reset=1 In_Data=3  ->  Out_H=0  Out_L=3
//   ** Note: $stop    : If_Reset_tb.v(27)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module If_Reset_tb at If_Reset_tb.v line 27
//
// 觀察重點：同一條 Reset：Reset=1 時 Out_H 清 0、Out_L 正常存資料；Reset=0 時剛好相反；兩者都只在 Clock 正緣動作（同步 Reset）


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Reg_RstHigh.v Reg_RstLow.v If_Reset_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.If_Reset_tb     Simulate > Start Simulation → work → If_Reset_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 If_Reset_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Reg_RstHigh.v、Reg_RstLow.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, If_Reset_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
