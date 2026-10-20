`timescale 1ns/1ps

// =====================================================================
// Traffic_Light_tb：紅綠燈控制器測試平台
//   時脈週期 10ns，跑兩輪完整的 紅 9 → 綠 6 → 黃 1
// =====================================================================
module Traffic_Light_tb;
    reg  Clock, Reset;
    wire RED, GREEN, YELLOW;

    Traffic_Light uut (.Clock(Clock), .Reset(Reset), .RED(RED), .GREEN(GREEN), .YELLOW(YELLOW));

    initial Clock = 0;
    always #5 Clock = ~Clock;           // 正緣在 5, 15, 25 ...

    initial begin
        // `define 是「全域」的：Traffic_Light.v 定義的巨集，同一次 vlog 編譯中、排在後面的檔案也能用
        $display("RED_Light_Time=%0d  GREEN_Light_Time=%0d  YELLOW_Light_Time=%0d",
                 `RED_Light_Time, `GREEN_Light_Time, `YELLOW_Light_Time);
        // 只監視燈號（Count_In 每個時脈都在變，放進來會印太多行）
        $monitor("t=%0d  Reset=%b  state=%b  RED=%b GREEN=%b YELLOW=%b",
                 $time, Reset, uut.state, RED, GREEN, YELLOW);
        Reset = 1;
        #12 Reset = 0;                  // 5ns 的正緣做完重置後放開
        #320 $stop;                     // 32 個時脈 = 兩輪 16 個時脈
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   RED_Light_Time=9  GREEN_Light_Time=6  YELLOW_Light_Time=1
//   t=0  Reset=1  state=xx  RED=x GREEN=x YELLOW=x
//   t=5  Reset=1  state=00  RED=1 GREEN=0 YELLOW=0
//   t=12  Reset=0  state=00  RED=1 GREEN=0 YELLOW=0
//   t=95  Reset=0  state=01  RED=0 GREEN=1 YELLOW=0
//   t=155  Reset=0  state=10  RED=0 GREEN=0 YELLOW=1
//   t=165  Reset=0  state=00  RED=1 GREEN=0 YELLOW=0
//   t=255  Reset=0  state=01  RED=0 GREEN=1 YELLOW=0
//   t=315  Reset=0  state=10  RED=0 GREEN=0 YELLOW=1
//   t=325  Reset=0  state=00  RED=1 GREEN=0 YELLOW=0
//   ** Note: $stop    : Traffic_Light_tb.v(25)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Traffic_Light_tb at Traffic_Light_tb.v line 25
//
// 觀察重點：紅燈 t=5~95 亮 9 個時脈（90ns）、綠燈 95~155 亮 6 個時脈、黃燈 155~165 亮 1 個時脈；把 `RED_Light_Time 改成別的數字重新編譯，紅燈的長度就跟著變


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Traffic_Light.v Traffic_Light_tb.v  Compile > Compile...（Traffic_Light.v 要排在前面）
//     2. 載入模擬   vsim -voptargs=+acc work.Traffic_Light_tb Simulate > Start Simulation → work → Traffic_Light_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Traffic_Light_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Traffic_Light.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Traffic_Light_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
