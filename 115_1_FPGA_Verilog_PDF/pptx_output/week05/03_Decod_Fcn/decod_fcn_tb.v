`timescale 1ns/1ps

// =====================================================================
// decod_fcn_tb：講義第 11 頁的測試平台，Din 每個時脈正緣加 1
// =====================================================================
module decod_fcn_tb;
    reg  [2:0] Din;
    wire [7:0] Y;
    reg        clk;

    decod_fcn uut (.Din(Din), .Y(Y));

    initial begin
        #0 Din = 3'b0;
           clk = 1'b0;
    end

    always #10 clk = ~clk;      // 週期 20ns，正緣在 10, 30, 50 ...

    always @(posedge clk) begin
        if (Din < 3'b111)
            Din <= Din + 1;     // 講義寫 Din = Din + 1；在時脈邊緣更新建議用 <=
        else
            Din <= 3'b000;
    end

    initial begin
        $monitor("t=%0d  Din=%b (%0d)  ->  Y=%b", $time, Din, Din, Y);
        #170 $stop;             // 講義沒寫結束條件，跑完 8 種輸入後停止
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Din=000 (0)  ->  Y=00000001
//   t=10  Din=001 (1)  ->  Y=00000010
//   t=30  Din=010 (2)  ->  Y=00000100
//   t=50  Din=011 (3)  ->  Y=00001000
//   t=70  Din=100 (4)  ->  Y=00010000
//   t=90  Din=101 (5)  ->  Y=00100000
//   t=110  Din=110 (6)  ->  Y=01000000
//   t=130  Din=111 (7)  ->  Y=10000000
//   t=150  Din=000 (0)  ->  Y=00000001
//   ** Note: $stop    : decod_fcn_tb.v(29)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module decod_fcn_tb at decod_fcn_tb.v line 29
//
// 觀察重點：Din=0~3 時 1 出現在低 4 位元（下半部函數動作），Din=4~7 時出現在高 4 位元；每次只有一個位元是 1


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog decod_fcn.v decod_fcn_tb.v          Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.decod_fcn_tb    Simulate > Start Simulation → work → decod_fcn_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 decod_fcn_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 decod_fcn.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, decod_fcn_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
