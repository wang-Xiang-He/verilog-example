`timescale 10ns/1ns         // `timescale <時間單位>/<時間精度>：時間單位 10ns、時間精度 1ns
                            //   開頭是反引號 `，講義第 18 頁印成了單引號 '，照抄會編譯錯誤

// =====================================================================
// time_scale：`timescale 範例（講義第 18 頁）
//   #p = #1.65 個時間單位 = 16.5ns → 依時間精度 1ns 四捨五入 → 17ns
//   只有這一個檔案，沒有電路本體
// =====================================================================
module time_scale;
    reg time_set;
    parameter p = 1.65;

    initial                     // 講義寫成 Initial（大寫 I），Verilog 關鍵字有分大小寫，要寫 initial
        $monitor("%t  time_set=%b      ($time=%0d  $realtime=%0.2f)",
                 $realtime, time_set, $time, $realtime);
    //   %t       ：以「模擬精度」為單位顯示時間；這裡精度是 1ns，所以數字就是 ns → 17、34，和講義一樣
    //   $time    ：以「這個模組的時間單位」（10ns）為單位，而且四捨五入成整數 → 1.7 變成 2
    //   $realtime：以時間單位為單位，保留小數 → 1.70

    initial begin
        #p time_set = 0;        // 16.5ns → 17ns
        #p time_set = 1;        // 再 17ns → 34ns（每個 #p 各自四捨五入：17 + 17）
        #1 $stop;               // #1 = 1 個時間單位 = 10ns → 在 44ns 停止
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//                      0  time_set=x      ($time=0  $realtime=0.00)
//                     17  time_set=0      ($time=2  $realtime=1.70)
//                     34  time_set=1      ($time=3  $realtime=3.40)
//   ** Note: $stop    : time_scale_tb.v(23)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module time_scale at time_scale_tb.v line 23
//
// 觀察重點：%t 印出 17、34（單位是模擬精度 1ns，和講義相同）；但 $time 印出 2、3，因為 $time 的單位是 10ns 而且只取整數——要看精確時間用 %t 或 $realtime


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog time_scale_tb.v                     Compile > Compile...
//     2. 載入模擬   vsim -voptargs=+acc work.time_scale      Simulate > Start Simulation → work → time_scale
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 time_scale > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 留空（這個範例沒有電路本體）
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, time_scale); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
