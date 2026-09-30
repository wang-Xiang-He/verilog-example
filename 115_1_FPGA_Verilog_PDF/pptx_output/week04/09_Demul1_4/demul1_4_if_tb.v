`timescale 1ns/1ps

// =====================================================================
// demul1_4_if_tb：講義第 29 頁的測試平台
//   用 3 位元計數器 data 產生所有輸入組合：I = data[2]，S1 = data[1]，S0 = data[0]
// =====================================================================
module demul1_4_if_tb;
    wire [3:0] y;
    wire       I;
    wire       S0, S1;
    reg        clk;
    reg  [2:0] data;

    demul1_4_if uut (.y(y), .I(I), .S0(S0), .S1(S1));

    initial begin
        clk  = 0;
        data = 3'b0;
    end

    always
        #10 clk = ~clk;         // 週期 20ns，正緣在 10, 30, 50 ...

    always @(posedge clk) begin
        if (data < 3'b111)
            data <= data + 1;   // 講義寫 data = data + 1；在時脈邊緣更新建議用 <=
        else
            data <= 3'b0;
    end

    assign I  = data[2];
    assign S1 = data[1];
    assign S0 = data[0];

    initial begin
        $monitor("t=%0d  I=%b S1=%b S0=%b  ->  y=%b", $time, I, S1, S0, y);
        #170 $stop;             // 講義沒寫結束條件，跑完 8 種組合後停止
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  I=0 S1=0 S0=0  ->  y=0000
//   t=10  I=0 S1=0 S0=1  ->  y=0000
//   t=30  I=0 S1=1 S0=0  ->  y=0000
//   t=50  I=0 S1=1 S0=1  ->  y=0000
//   t=70  I=1 S1=0 S0=0  ->  y=0001
//   t=90  I=1 S1=0 S0=1  ->  y=0010
//   t=110  I=1 S1=1 S0=0  ->  y=0100
//   t=130  I=1 S1=1 S0=1  ->  y=1000
//   t=150  I=0 S1=0 S0=0  ->  y=0000
//   ** Note: $stop    : demul1_4_if_tb.v(37)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module demul1_4_if_tb at demul1_4_if_tb.v line 37
//
// 觀察重點：I=0 時 y 全為 0；I=1 時 {S1,S0} 選到哪一位，那一位就是 1（0001 → 0010 → 0100 → 1000）


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog demul1_4_if.v demul1_4_if_tb.v      Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.demul1_4_if_tb  Simulate > Start Simulation → work → demul1_4_if_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 demul1_4_if_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 demul1_4_if.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, demul1_4_if_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
