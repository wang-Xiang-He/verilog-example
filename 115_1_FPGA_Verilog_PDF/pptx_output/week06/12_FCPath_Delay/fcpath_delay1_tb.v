`timescale 1ns/1ps

// =====================================================================
// fcpath_delay1_tb：完全連接路徑的測試平台
//   測試向量和講義相同：每 20ns 換一組 a1 a2 a3 a4
//   0000 → 1100 → 0000 → 0011 → 0000 → 1111 → 0000
//   $monitor 也把內部的 y1、y2 印出來，比較容易看出延遲是加在哪裡
// =====================================================================
module fcpath_delay1_tb;
    reg  a1, a2, a3, a4;
    wire y;

    fcpath_delay1 uut (.a1(a1), .a2(a2), .a3(a3), .a4(a4), .y(y));

    initial
        $monitor("t=%0d  a1=%b a2=%b a3=%b a4=%b  |  y1=%b y2=%b  |  y=%b",
                 $time, a1, a2, a3, a4, uut.y1, uut.y2, y);

    initial begin
        #0  a1 = 0; a2 = 0; a3 = 0; a4 = 0;
        #20 a1 = 1; a2 = 1; a3 = 0; a4 = 0;     // and1 的輸入變 11
        #20 a1 = 0; a2 = 0; a3 = 0; a4 = 0;
        #20 a1 = 0; a2 = 0; a3 = 1; a4 = 1;     // and2 的輸入變 11
        #20 a1 = 0; a2 = 0; a3 = 0; a4 = 0;
        #20 a1 = 1; a2 = 1; a3 = 1; a4 = 1;     // 兩個 AND 同時變 1
        #20 a1 = 0; a2 = 0; a3 = 0; a4 = 0;
        #20 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  a1=0 a2=0 a3=0 a4=0  |  y1=0 y2=0  |  y=x
//   t=10  a1=0 a2=0 a3=0 a4=0  |  y1=0 y2=0  |  y=0
//   t=20  a1=1 a2=1 a3=0 a4=0  |  y1=1 y2=0  |  y=0
//   t=30  a1=1 a2=1 a3=0 a4=0  |  y1=1 y2=0  |  y=1
//   t=40  a1=0 a2=0 a3=0 a4=0  |  y1=0 y2=0  |  y=1
//   t=50  a1=0 a2=0 a3=0 a4=0  |  y1=0 y2=0  |  y=0
//   t=60  a1=0 a2=0 a3=1 a4=1  |  y1=0 y2=1  |  y=0
//   t=72  a1=0 a2=0 a3=1 a4=1  |  y1=0 y2=1  |  y=1
//   t=80  a1=0 a2=0 a3=0 a4=0  |  y1=0 y2=0  |  y=1
//   t=92  a1=0 a2=0 a3=0 a4=0  |  y1=0 y2=0  |  y=0
//   t=100  a1=1 a2=1 a3=1 a4=1  |  y1=1 y2=1  |  y=0
//   t=110  a1=1 a2=1 a3=1 a4=1  |  y1=1 y2=1  |  y=1
//   t=120  a1=0 a2=0 a3=0 a4=0  |  y1=0 y2=0  |  y=1
//   t=130  a1=0 a2=0 a3=0 a4=0  |  y1=0 y2=0  |  y=0
//   ** Note: $stop    : fcpath_delay1_tb.v(27)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module fcpath_delay1_tb at fcpath_delay1_tb.v line 27
//
// 觀察重點：每一行都和 11_PPath_Delay 一模一樣：這裡輸入輸出都是 1 位元，=> 和 *> 沒有差別；只有向量（多位元）時兩者才不同


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog fcpath_delay1.v fcpath_delay1_tb.v  Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.fcpath_delay1_tb Simulate > Start Simulation → work → fcpath_delay1_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 fcpath_delay1_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 fcpath_delay1.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, fcpath_delay1_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
