`timescale 1ns/1ps

// =====================================================================
// System_Task_tb：系統函數與任務（講義第 35 頁）
//   $ 開頭的是模擬器內建的系統任務 / 系統函數，只能用在模擬，不會合成成電路
//   只有 testbench，沒有電路本體
// =====================================================================
module System_Task_tb;
    reg  [7:0] data;
    integer    i;

    // 自己寫的函數也可以和系統任務一起用：算 8 位元中有幾個 1
    function [3:0] count_ones (input [7:0] v);
        integer n;
        begin
            count_ones = 0;
            for (n = 0; n < 8; n = n + 1)
                count_ones = count_ones + v[n];
        end
    endfunction

    initial begin
        data = 8'b1010_0101;

        // ---------- $display：顯示後跳下一行 ----------
        $display("--- (1) $display ---");
        $display("data = %b", data);
        $display("data = %h (hex), %0d (dec), %o (oct)", data, data, data);
        $display("count_ones(data) = %0d", count_ones(data));

        // ---------- $write：顯示後游標留在同一行 ----------
        $display("--- (2) $write ---");
        for (i = 7; i >= 0; i = i - 1)
            $write("%b ", data[i]);         // 8 個位元印在同一行
        $write("\n");                       // 要自己加換行

        // ---------- $time：系統函數，回傳目前的模擬時間 ----------
        $display("--- (3) $time ---");
        $display("time = %0d", $time);
        #25;
        $display("time = %0d", $time);

        // ---------- $finish：跳離執行中的模擬程式 ----------
        // 講義用 $finish；在 ModelSim 圖形介面執行 $finish 會跳出「是否關閉 ModelSim」的詢問視窗，
        // 所以這裡和其他範例一樣改用 $stop（暫停模擬，Transcript 和波形都保留）
        $display("--- (4) $stop ---");
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   --- (1) $display ---
//   data = 10100101
//   data = a5 (hex), 165 (dec), 245 (oct)
//   count_ones(data) = 4
//   --- (2) $write ---
//   1 0 1 0 0 1 0 1
//   --- (3) $time ---
//   time = 0
//   time = 25
//   --- (4) $stop ---
//   ** Note: $stop    : System_Task_tb.v(47)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module System_Task_tb at System_Task_tb.v line 47
//
// 觀察重點：$display 會自動換行；$write 不會，8 個位元印在同一行；$time 回傳目前的模擬時間


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog System_Task_tb.v                    Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.System_Task_tb  Simulate > Start Simulation → work → System_Task_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 System_Task_tb > Add Wave
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
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, System_Task_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
