`timescale 1ns/1ps

// =====================================================================
// ScalableDesign_tb：同一個模組做出 16 位元與 4 位元兩個電路
// =====================================================================
module ScalableDesign_tb;
    reg  [15:0] a16, b16;
    wire [15:0] c16;
    reg  [3:0]  a4, b4;
    wire [3:0]  c4;

    ScalableDesign                u16 (.a(a16), .b(b16), .c(c16));  // 用預設 width = 16
    ScalableDesign #(.width(4))   u4  (.a(a4),  .b(b4),  .c(c4));   // 覆寫成 width = 4

    initial begin
        $monitor("t=%0d  16-bit: %h & %h = %h   |   4-bit: %b & %b = %b",
                 $time, a16, b16, c16, a4, b4, c4);
        a16 = 16'hFFFF; b16 = 16'h1234; a4 = 4'b1111; b4 = 4'b1010; #10;
        a16 = 16'hF0F0; b16 = 16'hABCD; a4 = 4'b1100; b4 = 4'b0110; #10;
        $display("u16.width = %0d,  u4.width = %0d", u16.width, u4.width);
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  16-bit: ffff & 1234 = 1234   |   4-bit: 1111 & 1010 = 1010
//   t=10  16-bit: f0f0 & abcd = a0c0   |   4-bit: 1100 & 0110 = 0100
//   u16.width = 16,  u4.width = 4
//   ** Note: $stop    : ScalableDesign_tb.v(21)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module ScalableDesign_tb at ScalableDesign_tb.v line 21
//
// 觀察重點：同一個 ScalableDesign 模組，u16 用預設 width=16，u4 用 #(.width(4)) 覆寫成 4 位元


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog ScalableDesign.v ScalableDesign_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.ScalableDesign_tb Simulate > Start Simulation → work → ScalableDesign_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 ScalableDesign_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 ScalableDesign.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, ScalableDesign_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
