`timescale 1ns/1ps

// =====================================================================
// Counter4_5_tb：Counter4（旗標在 always 內）與 Counter5（旗標在 always 外）一起測
//   (1) 重置後的前 6 個時脈
//   (2) 跳到 1021 ~ 1023 → 0，看 Max_1023 和 Zero
//   Even / Odd 是「同位」（1 的個數），不是數值的奇偶：例如 3 = 0000000011 有兩個 1 → Even = 1
// =====================================================================
module Counter4_5_tb;
    reg        Clock, Reset;
    wire [9:0] Out4, Out5;
    wire       Z4, M4, E4, O4, Z5, M5, E5, O5;
    reg        show;

    initial Clock = 1'b0;
    always #5 Clock = ~Clock;           // 週期 10ns，正緣在 5、15、25 ...

    Counter4 u4 (.Clock(Clock), .Reset(Reset), .Zero(Z4), .Max_1023(M4), .Even(E4), .Odd(O4), .Out(Out4));
    Counter5 u5 (.Clock(Clock), .Reset(Reset), .Zero(Z5), .Max_1023(M5), .Even(E5), .Odd(O5), .Out(Out5));

    always @(negedge Clock)
        if (show)
            $display("t=%0d  Out=%b(%0d)  | Counter4: Zero=%b Max=%b Even=%b Odd=%b  | Counter5: Zero=%b Max=%b Even=%b Odd=%b",
                     $time, Out5, Out5, Z4, M4, E4, O4, Z5, M5, E5, O5);

    initial begin
        show = 1;
            Reset = 1;
        #12 Reset = 0;
        #60 show = 0;                           // 中間 1000 多個時脈不印
        wait (Out5 == 10'd1020);
        @(posedge Clock) show = 1;
        #50 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Out=xxxxxxxxxx(x)  | Counter4: Zero=x Max=x Even=x Odd=x  | Counter5: Zero=x Max=x Even=x Odd=x
//   t=10  Out=0000000000(0)  | Counter4: Zero=1 Max=0 Even=1 Odd=0  | Counter5: Zero=1 Max=0 Even=1 Odd=0
//   t=20  Out=0000000001(1)  | Counter4: Zero=1 Max=0 Even=1 Odd=0  | Counter5: Zero=0 Max=0 Even=0 Odd=1
//   t=30  Out=0000000010(2)  | Counter4: Zero=0 Max=0 Even=0 Odd=1  | Counter5: Zero=0 Max=0 Even=0 Odd=1
//   t=40  Out=0000000011(3)  | Counter4: Zero=0 Max=0 Even=0 Odd=1  | Counter5: Zero=0 Max=0 Even=1 Odd=0
//   t=50  Out=0000000100(4)  | Counter4: Zero=0 Max=0 Even=1 Odd=0  | Counter5: Zero=0 Max=0 Even=0 Odd=1
//   t=60  Out=0000000101(5)  | Counter4: Zero=0 Max=0 Even=0 Odd=1  | Counter5: Zero=0 Max=0 Even=1 Odd=0
//   t=70  Out=0000000110(6)  | Counter4: Zero=0 Max=0 Even=1 Odd=0  | Counter5: Zero=0 Max=0 Even=1 Odd=0
//   t=10220  Out=1111111101(1021)  | Counter4: Zero=0 Max=0 Even=1 Odd=0  | Counter5: Zero=0 Max=0 Even=0 Odd=1
//   t=10230  Out=1111111110(1022)  | Counter4: Zero=0 Max=0 Even=0 Odd=1  | Counter5: Zero=0 Max=0 Even=0 Odd=1
//   t=10240  Out=1111111111(1023)  | Counter4: Zero=0 Max=0 Even=0 Odd=1  | Counter5: Zero=0 Max=1 Even=1 Odd=0
//   t=10250  Out=0000000000(0)  | Counter4: Zero=0 Max=1 Even=1 Odd=0  | Counter5: Zero=1 Max=0 Even=1 Odd=0
//   t=10260  Out=0000000001(1)  | Counter4: Zero=1 Max=0 Even=1 Odd=0  | Counter5: Zero=0 Max=0 Even=0 Odd=1
//   ** Note: $stop    : Counter4_5_tb.v(33)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Counter4_5_tb at Counter4_5_tb.v line 33
//
// 觀察重點：Counter5 的旗標永遠對應目前的 Out（Out=0 時 Zero=1、Out=1023 時 Max=1、Out=3 時 Even=1）；Counter4 的旗標都晚一個時脈，因為 <= 用的是加 1 之前的 Out


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Counter4.v Counter5.v Counter4_5_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Counter4_5_tb   Simulate > Start Simulation → work → Counter4_5_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Counter4_5_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Counter4.v、Counter5.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Counter4_5_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
