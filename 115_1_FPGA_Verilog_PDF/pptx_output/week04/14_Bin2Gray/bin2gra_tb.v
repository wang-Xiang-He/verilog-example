`timescale 1ns/1ps

// =====================================================================
// bin2gra_tb：講義第 45 頁的測試平台，Bin 每個時脈正緣加 1
// =====================================================================
module bin2gra_tb;
    parameter length = 8;
    wire [length-1:0] Gry;
    reg  [length-1:0] Bin;
    reg               clk;

    bin2gra #(.length(length)) uut (.Gry(Gry), .Bin(Bin));

    initial begin
        Bin = 0;
        clk = 0;
    end

    always
        #5 clk = !clk;              // 週期 10ns，正緣在 5, 15, 25 ...

    always @(posedge clk)
        Bin <= Bin + 1;             // 講義寫 Bin = Bin + 1

    initial begin
        $monitor("t=%0d  Bin=%b (%0d)  ->  Gry=%b", $time, Bin, Bin, Gry);
        #160 $stop;                 // 講義沒寫結束條件；看前 16 個值就夠了
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Bin=00000000 (0)  ->  Gry=00000000
//   t=5  Bin=00000001 (1)  ->  Gry=00000001
//   t=15  Bin=00000010 (2)  ->  Gry=00000011
//   t=25  Bin=00000011 (3)  ->  Gry=00000010
//   t=35  Bin=00000100 (4)  ->  Gry=00000110
//   t=45  Bin=00000101 (5)  ->  Gry=00000111
//   t=55  Bin=00000110 (6)  ->  Gry=00000101
//   t=65  Bin=00000111 (7)  ->  Gry=00000100
//   t=75  Bin=00001000 (8)  ->  Gry=00001100
//   t=85  Bin=00001001 (9)  ->  Gry=00001101
//   t=95  Bin=00001010 (10)  ->  Gry=00001111
//   t=105  Bin=00001011 (11)  ->  Gry=00001110
//   t=115  Bin=00001100 (12)  ->  Gry=00001010
//   t=125  Bin=00001101 (13)  ->  Gry=00001011
//   t=135  Bin=00001110 (14)  ->  Gry=00001001
//   t=145  Bin=00001111 (15)  ->  Gry=00001000
//   t=155  Bin=00010000 (16)  ->  Gry=00011000
//   ** Note: $stop    : bin2gra_tb.v(27)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module bin2gra_tb at bin2gra_tb.v line 27
//
// 觀察重點：相鄰兩個格雷碼只差 1 個位元（例如 7→8：00000100 → 00001100）


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog bin2gra.v bin2gra_tb.v              Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.bin2gra_tb      Simulate > Start Simulation → work → bin2gra_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 bin2gra_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 bin2gra.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, bin2gra_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
