`timescale 1ns/1ps

// =====================================================================
// dff_tb：D 型正反器測試平台（講義第 31 頁）
// =====================================================================
module dff_tb;
    reg  din, clk;
    wire q;

    dff top (.din(din), .clk(clk), .q(q));

    initial begin
        #0 din <= 0;
           clk <= 0;
    end

    always begin
        #5 clk <= !clk;       // 時脈週期 10ns，正緣在 5, 15, 25 ...
    end

    always begin
        #10 din <= !din;      // din 每 10ns 反相，變化點在 10, 20, 30 ...
    end

    initial begin
        $monitor("t=%0d  clk=%b din=%b  q=%b", $time, clk, din, q);
        #60 $stop;            // 講義沒寫結束條件，這裡補上，不然會無限執行
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  clk=0 din=0  q=x
//   t=5  clk=1 din=0  q=0
//   t=10  clk=0 din=1  q=0
//   t=15  clk=1 din=1  q=1
//   t=20  clk=0 din=0  q=1
//   t=25  clk=1 din=0  q=0
//   t=30  clk=0 din=1  q=0
//   t=35  clk=1 din=1  q=1
//   t=40  clk=0 din=0  q=1
//   t=45  clk=1 din=0  q=0
//   t=50  clk=0 din=1  q=0
//   t=55  clk=1 din=1  q=1
//   ** Note: $stop    : dff_tb.v(27)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module dff_tb at dff_tb.v line 27
//
// 觀察重點：觀察重點：q 只在 clk 由 0 變 1（正緣）時才跟著 din 改變，其他時間 din 怎麼變 q 都不動


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog dff.v dff_tb.v                      Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.dff_tb          Simulate > Start Simulation → work → dff_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 dff_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 dff.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, dff_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
