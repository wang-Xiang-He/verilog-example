`timescale 1ns/1ps

// =====================================================================
// DeMux1X2_tb：兩種 1 對 2 解多工器一起測
//   講義第 46 頁的模擬結果標了「Error」：那張圖其實是 4 對 1 多工器的波形（貼錯圖），不是本電路的
// =====================================================================
module DeMux1X2_tb;
    reg  D, Select;
    wire Y0_1, Y1_1, Y0_2, Y1_2;
    integer k;

    DeMux1X2_1 u1 (.D(D), .Select(Select), .Y0(Y0_1), .Y1(Y1_1));
    DeMux1X2_2 u2 (.D(D), .Select(Select), .Y0(Y0_2), .Y1(Y1_2));

    initial begin
        $monitor("t=%0d  Select=%b D=%b  ->  _1(assign): Y0=%b Y1=%b   _2(if): Y0=%b Y1=%b",
                 $time, Select, D, Y0_1, Y1_1, Y0_2, Y1_2);
        for (k = 0; k < 4; k = k + 1) begin
            {Select, D} = k; #10;
        end
        Select = 1'bx; D = 1'b1; #10;   // Select 不確定（講義第 48 頁波形紅色那段）
        Select = 1'bx; D = 1'b0; #10;   // 再改 D：_2 的輸出完全不動（latch 行為）
        Select = 1'b0; D = 1'b1; #10;
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Select=0 D=0  ->  _1(assign): Y0=0 Y1=0   _2(if): Y0=0 Y1=0
//   t=10  Select=0 D=1  ->  _1(assign): Y0=1 Y1=0   _2(if): Y0=1 Y1=0
//   t=20  Select=1 D=0  ->  _1(assign): Y0=0 Y1=0   _2(if): Y0=0 Y1=0
//   t=30  Select=1 D=1  ->  _1(assign): Y0=0 Y1=1   _2(if): Y0=0 Y1=1
//   t=40  Select=x D=1  ->  _1(assign): Y0=x Y1=x   _2(if): Y0=0 Y1=1
//   t=50  Select=x D=0  ->  _1(assign): Y0=0 Y1=0   _2(if): Y0=0 Y1=1
//   t=60  Select=0 D=1  ->  _1(assign): Y0=1 Y1=0   _2(if): Y0=1 Y1=0
//   ** Note: $stop    : DeMux1X2_tb.v(24)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module DeMux1X2_tb at DeMux1X2_tb.v line 24
//
// 觀察重點：Select 是 0 / 1 時兩種寫法一樣；Select = x 時 _1 依布林方程式算出 x（D=1）或 0（D=0），_2 兩個 if 都不成立，Y0、Y1 停在舊值，D 怎麼變都不動


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog DeMux1X2_1.v DeMux1X2_2.v DeMux1X2_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.DeMux1X2_tb     Simulate > Start Simulation → work → DeMux1X2_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 DeMux1X2_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 DeMux1X2_1.v、DeMux1X2_2.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, DeMux1X2_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
