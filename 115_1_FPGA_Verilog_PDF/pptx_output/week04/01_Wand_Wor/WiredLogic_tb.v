`timescale 1ns/1ps

// =====================================================================
// WiredLogic_tb：同時測試 wand / wor / wire 三種線，比較多重驅動的結果
// =====================================================================
module WiredLogic_tb;
    reg  a, b;
    wire c_wand, c_wor, c_wire;

    wand_test u_and  (.a(a), .b(b), .c(c_wand));
    wor_test  u_or   (.a(a), .b(b), .c(c_wor));
    wire_test u_wire (.a(a), .b(b), .c(c_wire));

    initial begin
        $monitor("t=%0d  a=%b b=%b  ->  wand=%b  wor=%b  wire=%b",
                 $time, a, b, c_wand, c_wor, c_wire);
        a = 0; b = 0; #10;
        a = 0; b = 1; #10;
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  a=0 b=0  ->  wand=0  wor=0  wire=0
//   t=10  a=0 b=1  ->  wand=0  wor=1  wire=x
//   t=20  a=1 b=0  ->  wand=0  wor=1  wire=x
//   t=30  a=1 b=1  ->  wand=1  wor=1  wire=1
//   ** Note: $stop    : WiredLogic_tb.v(21)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module WiredLogic_tb at WiredLogic_tb.v line 21
//
// 觀察重點：wand 只有 a、b 都是 1 才輸出 1（AND）；wor 任一個是 1 就輸出 1（OR）；一般 wire 兩個驅動值不同時變成 x


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog wand_test.v wor_test.v wire_test.v WiredLogic_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.WiredLogic_tb   Simulate > Start Simulation → work → WiredLogic_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 WiredLogic_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 wand_test.v、wor_test.v、wire_test.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, WiredLogic_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
