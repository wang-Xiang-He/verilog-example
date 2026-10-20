`timescale 1ns/1ps

// =====================================================================
// FreqModN_tb：4 種除頻器一起測，N = 5（講義第 57 頁的 Data_N = 0101）和 N = 6
//   Clock_In 週期 10ns；每種輸出自動量測「週期」與「高電位時間」，換算成幾個 Clock_In
// =====================================================================
module FreqModN_tb;
    reg        LoadModN, Clock_In;
    reg  [3:0] Data_N;
    wire [3:0] out;                 // {Duty50_Fix, Duty50, Fix, 原版}
    integer    n;

    initial Clock_In = 1'b0;
    always #5 Clock_In = ~Clock_In;

    FreqModN            u0 (.LoadModN(LoadModN), .Data_N(Data_N), .Clock_In(Clock_In), .Clock_ModN_Out(out[0]));
    FreqModN_Fix        u1 (.LoadModN(LoadModN), .Data_N(Data_N), .Clock_In(Clock_In), .Clock_ModN_Out(out[1]));
    FreqModN_Duty50     u2 (.LoadModN(LoadModN), .Data_N(Data_N), .Clock_In(Clock_In), .Clock_ModN_Out(out[2]));
    FreqModN_Duty50_Fix u3 (.LoadModN(LoadModN), .Data_N(Data_N), .Clock_In(Clock_In), .Clock_ModN_Out(out[3]));

    // 量測：記錄每個輸出最近一次上升、下降的時間
    time rise [0:3], fall [0:3], period [0:3], high [0:3];
    genvar g;
    generate for (g = 0; g < 4; g = g + 1) begin : meas
        always @(posedge out[g]) begin
            if (rise[g] > 0) period[g] = $time - rise[g];
            rise[g] = $time;
        end
        always @(negedge out[g]) begin
            fall[g] = $time;
            if (rise[g] > 0) high[g] = $time - rise[g];
        end
    end endgenerate

    task run_n (input [3:0] N);
        integer k;
        begin
            for (k = 0; k < 4; k = k + 1) begin rise[k] = 0; period[k] = 0; high[k] = 0; end
            Data_N = N;
            @(negedge Clock_In) LoadModN = 0;   // 載入一個時脈
            @(negedge Clock_In) LoadModN = 1;
            #400;                               // 跑 40 個時脈
            $display("N = %0d:", N);
            $display("  FreqModN            (original)  period = %0d clocks, high = %0d clocks", period[0]/10, high[0]/10);
            $display("  FreqModN_Fix        (- 1)       period = %0d clocks, high = %0d clocks", period[1]/10, high[1]/10);
            $display("  FreqModN_Duty50     (slide 59)  period = %0d clocks, high = %0d clocks", period[2]/10, high[2]/10);
            $display("  FreqModN_Duty50_Fix (N/2 - 1)   period = %0d clocks, high = %0d clocks", period[3]/10, high[3]/10);
        end
    endtask

    initial begin
        LoadModN = 1; Data_N = 4'd5;
        // 先印出 N = 5 時前 14 個時脈的波形（講義第 57 頁）
        $display("after posedge   : orig Fix Duty50 Duty50_Fix");     // 字串用英文，避免 Transcript 中文亂碼
        @(negedge Clock_In) LoadModN = 0;
        @(negedge Clock_In) LoadModN = 1;
        for (n = 0; n < 14; n = n + 1)
            @(negedge Clock_In) $display("  t=%3d          :   %b    %b     %b       %b", $time, out[0], out[1], out[2], out[3]);
        run_n(4'd5);
        run_n(4'd6);
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   after posedge   : orig Fix Duty50 Duty50_Fix
//     t= 30          :   0    0     0       0
//     t= 40          :   0    0     0       1
//     t= 50          :   0    0     1       1
//     t= 60          :   0    0     1       0
//     t= 70          :   0    1     1       0
//     t= 80          :   1    0     0       1
//     t= 90          :   0    0     0       1
//     t=100          :   0    0     0       0
//     t=110          :   0    0     1       0
//     t=120          :   0    1     1       1
//     t=130          :   0    0     1       1
//     t=140          :   1    0     0       0
//     t=150          :   0    0     0       0
//     t=160          :   0    0     0       1
//   N = 5:
//     FreqModN            (original)  period = 6 clocks, high = 1 clocks
//     FreqModN_Fix        (- 1)       period = 5 clocks, high = 1 clocks
//     FreqModN_Duty50     (slide 59)  period = 6 clocks, high = 3 clocks
//     FreqModN_Duty50_Fix (N/2 - 1)   period = 4 clocks, high = 2 clocks
//   N = 6:
//     FreqModN            (original)  period = 7 clocks, high = 1 clocks
//     FreqModN_Fix        (- 1)       period = 6 clocks, high = 1 clocks
//     FreqModN_Duty50     (slide 59)  period = 8 clocks, high = 4 clocks
//     FreqModN_Duty50_Fix (N/2 - 1)   period = 6 clocks, high = 3 clocks
//   ** Note: $stop    : FreqModN_tb.v(61)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module FreqModN_tb at FreqModN_tb.v line 61
//
// 觀察重點：原版 N=5 時週期是 6（講義第 57 頁「÷6 ⇒ Not ÷5」），改成 ReadIn_Count - 1 後才是 5；講義第 59 頁的 50% 版本 N=5 週期 6、N=6 週期 8，改成 N/2 - 1 後 N=6 剛好是 6、高低各 3 個時脈


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog FreqModN.v FreqModN_Fix.v FreqModN_Duty50.v FreqModN_Duty50_Fix.v FreqModN_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.FreqModN_tb     Simulate > Start Simulation → work → FreqModN_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 FreqModN_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 FreqModN.v、FreqModN_Fix.v、FreqModN_Duty50.v、FreqModN_Duty50_Fix.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, FreqModN_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
