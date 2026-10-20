`timescale 1ns/1ps

// =====================================================================
// mux4_1pr_tb：4 對 1 多工器測試平台（講義第 5、6 頁）
//   測試數值和講義相同：DI 故意放 x，看被選到的位元是 0、1 還是 x
//   講義用 `timescale 1ps/1ps、每 #1 換一組；這裡改成 1ns、每 #10 換一組，比較好讀
// =====================================================================
module mux4_1pr_tb;
    reg  [3:0] DI;
    reg  [1:0] Sel;
    wire       OUT;

    mux4_1pr uut (.OUT(OUT), .DI(DI), .Sel(Sel));   // mux4_1pr 是一般 module，可以依名稱連接

    initial begin
        $monitor("t=%0d  Sel=%b  DI[3:0]=%b  ->  OUT=%b", $time, Sel, DI, OUT);
            DI = 4'b0000;  Sel = 2'b00;
        #10 DI = 4'bxx00;               // Sel = 00 → 看 DI[0]
        #10 DI = 4'bxx01;
        #10 DI = 4'b00xx;
        #10 DI = 4'b01xx;
        #10 DI = 4'bxx00;  Sel = 2'b10; // Sel = 10 → 看 DI[2]
        #10 DI = 4'bxx01;
        #10 DI = 4'b00xx;
        #10 DI = 4'b01xx;
        #10 DI = 4'bxxxx;
        #10 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Sel=00  DI[3:0]=0000  ->  OUT=0
//   t=10  Sel=00  DI[3:0]=xx00  ->  OUT=0
//   t=20  Sel=00  DI[3:0]=xx01  ->  OUT=1
//   t=30  Sel=00  DI[3:0]=00xx  ->  OUT=x
//   t=40  Sel=00  DI[3:0]=01xx  ->  OUT=x
//   t=50  Sel=10  DI[3:0]=xx00  ->  OUT=x
//   t=60  Sel=10  DI[3:0]=xx01  ->  OUT=x
//   t=70  Sel=10  DI[3:0]=00xx  ->  OUT=0
//   t=80  Sel=10  DI[3:0]=01xx  ->  OUT=1
//   t=90  Sel=10  DI[3:0]=xxxx  ->  OUT=x
//   ** Note: $stop    : mux4_1pr_tb.v(27)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module mux4_1pr_tb at mux4_1pr_tb.v line 27
//
// 觀察重點：Sel=00 時 OUT = DI[0]：0、1、x、x；Sel=10 時 OUT = DI[2]：x、x、0、1、x（和講義第 6 頁相同）；沒被選到的位元就算是 x 也不影響輸出


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog mux2_1pr.v mux4_1pr.v mux4_1pr_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.mux4_1pr_tb     Simulate > Start Simulation → work → mux4_1pr_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 mux4_1pr_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 mux2_1pr.v、mux4_1pr.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, mux4_1pr_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
