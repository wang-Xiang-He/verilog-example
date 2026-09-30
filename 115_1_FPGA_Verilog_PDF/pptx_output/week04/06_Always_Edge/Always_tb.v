`timescale 1ns/1ps

// =====================================================================
// Always_tb：同樣的 f = a & b & c，比較位準觸發 / 正緣觸發 / 負緣觸發
// =====================================================================
module Always_tb;
    reg  Clock, a, b, c;
    wire f_level, f_pos, f_neg;

    And3_Level   u_lv  (.a(a), .b(b), .c(c), .f(f_level));
    And3_Posedge u_pos (.Clock(Clock), .a(a), .b(b), .c(c), .f(f_pos));
    And3_Negedge u_neg (.Clock(Clock), .a(a), .b(b), .c(c), .f(f_neg));

    // 時脈週期 20ns：正緣在 10, 30, 50 ...，負緣在 20, 40, 60 ...
    initial Clock = 0;
    always #10 Clock = ~Clock;

    initial begin
        $monitor("t=%0d  Clock=%b  abc=%b%b%b  ->  level=%b  posedge=%b  negedge=%b",
                 $time, Clock, a, b, c, f_level, f_pos, f_neg);
        a = 1; b = 1; c = 0;
        #15 c = 1;          // t=15：輸入在兩個時脈邊緣之間改變
        #10 c = 0;          // t=25
        #10 c = 1;          // t=35
        #30 $stop;          // t=65
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Clock=0  abc=110  ->  level=0  posedge=x  negedge=0
//   t=10  Clock=1  abc=110  ->  level=0  posedge=0  negedge=0
//   t=15  Clock=1  abc=111  ->  level=1  posedge=0  negedge=0
//   t=20  Clock=0  abc=111  ->  level=1  posedge=0  negedge=1
//   t=25  Clock=0  abc=110  ->  level=0  posedge=0  negedge=1
//   t=30  Clock=1  abc=110  ->  level=0  posedge=0  negedge=1
//   t=35  Clock=1  abc=111  ->  level=1  posedge=0  negedge=1
//   t=40  Clock=0  abc=111  ->  level=1  posedge=0  negedge=1
//   t=50  Clock=1  abc=111  ->  level=1  posedge=1  negedge=1
//   t=60  Clock=0  abc=111  ->  level=1  posedge=1  negedge=1
//   ** Note: $stop    : Always_tb.v(25)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Always_tb at Always_tb.v line 25
//
// 觀察重點：level 跟著輸入立刻變；posedge 只在 Clock 0→1（10, 30, 50）更新；negedge 只在 Clock 1→0（20, 40, 60）更新；t=0 時 Clock 從 x 變 0 也算負緣


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog And3_Level.v And3_Posedge.v And3_Negedge.v Always_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Always_tb       Simulate > Start Simulation → work → Always_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Always_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 And3_Level.v、And3_Posedge.v、And3_Negedge.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Always_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
