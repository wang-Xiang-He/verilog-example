`timescale 1ns/1ps

// =====================================================================
// repeat_1s_tb：使用講義第 48 頁模擬結果中的 9 筆 Din，每 10ns 換一筆
//   講義第 49 頁的測試平台是讓 Din 從 0 數到 255，輸出太多，這裡改成固定幾筆
// =====================================================================
module repeat_1s_tb;
    parameter length = 8;
    wire [3:0]        ones;
    reg  [length-1:0] Din;

    repeat_1s #(.length(length)) uut (.ones(ones), .Din(Din));

    initial begin
        $monitor("t=%0d  ones = %0d,  Din = %b", $time, ones, Din);
        Din = 8'b0000_0000; #10;
        Din = 8'b0101_0101; #10;
        Din = 8'b1100_1101; #10;
        Din = 8'b0000_0100; #10;
        Din = 8'b1111_0101; #10;
        Din = 8'b0110_0111; #10;
        Din = 8'b1000_0010; #10;
        Din = 8'b0011_1100; #10;
        Din = 8'b1011_0101; #10;
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  ones = 0,  Din = 00000000
//   t=10  ones = 4,  Din = 01010101
//   t=20  ones = 5,  Din = 11001101
//   t=30  ones = 1,  Din = 00000100
//   t=40  ones = 6,  Din = 11110101
//   t=50  ones = 5,  Din = 01100111
//   t=60  ones = 2,  Din = 10000010
//   t=70  ones = 4,  Din = 00111100
//   t=80  ones = 5,  Din = 10110101
//   ** Note: $stop    : repeat_1s_tb.v(25)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module repeat_1s_tb at repeat_1s_tb.v line 25
//
// 觀察重點：結果和講義第 48 頁的模擬結果完全相同


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog repeat_1s.v repeat_1s_tb.v          Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.repeat_1s_tb    Simulate > Start Simulation → work → repeat_1s_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 repeat_1s_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 repeat_1s.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, repeat_1s_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
