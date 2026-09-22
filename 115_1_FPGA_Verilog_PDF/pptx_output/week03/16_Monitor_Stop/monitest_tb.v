`timescale 1ns/1ps

// =====================================================================
// monitest：講義第 20 頁的 $monitor 範例
//   $display 被呼叫一次只印一次；$monitor 只要清單中的變數有變化就自動再印一次
// =====================================================================
module monitest;
    integer s, t;

    initial begin
        s = 4;
        t = 6;
        forever begin
            #5 s = s + t;
            #5 t = s - 1;
        end
    end

    initial $monitor($time, "  s=%0d, t=%0d", s, t);

    // $strobe：在「這個時間點所有變化都結束之後」才印，適合看最終穩定值
    initial #12 $strobe("[strobe] t=%0d  s=%0d, t=%0d", $time, s, t);

    // 講義原本用 #40 $finish（結束模擬、關閉模擬器）
    // ModelSim 改用 $stop（暫停模擬，Transcript 和波形都保留）
    initial #40 $stop;
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//                      0  s=4, t=6
//                      5  s=10, t=6
//                     10  s=10, t=9
//   [strobe] t=12  s=10, t=9
//                     15  s=19, t=9
//                     20  s=19, t=18
//                     25  s=37, t=18
//                     30  s=37, t=36
//                     35  s=73, t=36
//   ** Note: $stop    : monitest_tb.v(26)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module monitest at monitest_tb.v line 26
//
// 觀察重點：$time 的顯示寬度是固定的，所以數字前面會有很多空白；講義第 20 頁的執行結果表格可以直接對照


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog monitest_tb.v                       Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.monitest        Simulate > Start Simulation → work → monitest
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 monitest > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 留空（本範例只有 testbench）
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, monitest); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
