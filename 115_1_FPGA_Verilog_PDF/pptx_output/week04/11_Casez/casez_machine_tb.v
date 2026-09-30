`timescale 1ns/1ps

// =====================================================================
// casez_machine_tb：Condition 依序給 00、01、10、11，再故意給含 x / z 的值
// =====================================================================
module casez_machine_tb;
    reg        Clock;
    reg  [1:0] Condition;
    wire [2:0] Out;

    casez_machine uut (.Clock(Clock), .Condition(Condition), .Out(Out));

    // 時脈週期 10ns，正緣在 5, 15, 25 ...；Condition 在 0, 10, 20 ... 改變
    initial Clock = 0;
    always #5 Clock = ~Clock;

    initial begin
        $monitor("t=%0d  Clock=%b Condition=%b  ->  Out=%b", $time, Clock, Condition, Out);
        Condition = 2'b00;
        #10 Condition = 2'b01;
        #10 Condition = 2'b10;
        #10 Condition = 2'b11;
        #10 Condition = 2'b1x;   // 最低位元是 x
        #10 Condition = 2'bx0;   // 最高位元是 x，最低位元 0
        #10 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Clock=0 Condition=00  ->  Out=xxx
//   t=5  Clock=1 Condition=00  ->  Out=000
//   t=10  Clock=0 Condition=01  ->  Out=000
//   t=15  Clock=1 Condition=01  ->  Out=001
//   t=20  Clock=0 Condition=10  ->  Out=001
//   t=25  Clock=1 Condition=10  ->  Out=000
//   t=30  Clock=0 Condition=11  ->  Out=000
//   t=35  Clock=1 Condition=11  ->  Out=001
//   t=40  Clock=0 Condition=1x  ->  Out=001
//   t=45  Clock=1 Condition=1x  ->  Out=111
//   t=50  Clock=0 Condition=x0  ->  Out=111
//   t=55  Clock=1 Condition=x0  ->  Out=000
//   ** Note: $stop    : casez_machine_tb.v(25)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module casez_machine_tb at casez_machine_tb.v line 25
//
// 觀察重點：Out 只在時脈正緣更新；Condition=10 和 00 結果相同（最高位元不在乎）；最低位元是 x 時走 default（111）


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog casez_machine.v casez_machine_tb.v  Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.casez_machine_tb Simulate > Start Simulation → work → casez_machine_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 casez_machine_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 casez_machine.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, casez_machine_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
