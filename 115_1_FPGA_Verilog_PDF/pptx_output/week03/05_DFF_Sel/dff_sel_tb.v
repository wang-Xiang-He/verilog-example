`timescale 1ns/1ps

// =====================================================================
// dff_sel_tb：正反器選擇電路測試平台
//   （講義第 32 頁的 testbench 字太小看不清楚，這裡依相同結構改寫）
// =====================================================================
module dff_sel_tb;
    reg  da, db, sel, clk;
    wire q;

    dff_sel dff (.da(da), .db(db), .sel(sel), .clk(clk), .q(q));

    initial begin
        da  <= 0;
        db  <= 0;
        sel <= 0;
        clk <= 0;
    end

    always #5  clk <= !clk;    // 時脈週期 10ns
    always #20 da  <= !da;     // da 每 20ns 反相
    always #30 db  <= !db;     // db 每 30ns 反相
    always #40 sel <= !sel;    // sel 每 40ns 切換一次

    initial begin
        $monitor("t=%0d  clk=%b da=%b db=%b sel=%b  qa=%b qb=%b  q=%b",
                 $time, clk, da, db, sel, dff.qa, dff.qb, q);
        #120 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  clk=0 da=0 db=0 sel=0  qa=x qb=x  q=x
//   t=5  clk=1 da=0 db=0 sel=0  qa=0 qb=0  q=0
//   t=10  clk=0 da=0 db=0 sel=0  qa=0 qb=0  q=0
//   t=15  clk=1 da=0 db=0 sel=0  qa=0 qb=0  q=0
//   t=20  clk=0 da=1 db=0 sel=0  qa=0 qb=0  q=0
//   t=25  clk=1 da=1 db=0 sel=0  qa=1 qb=0  q=1
//   t=30  clk=0 da=1 db=1 sel=0  qa=1 qb=0  q=1
//   t=35  clk=1 da=1 db=1 sel=0  qa=1 qb=1  q=1
//   t=40  clk=0 da=0 db=1 sel=1  qa=1 qb=1  q=1
//   t=45  clk=1 da=0 db=1 sel=1  qa=0 qb=1  q=1
//   t=50  clk=0 da=0 db=1 sel=1  qa=0 qb=1  q=1
//   t=55  clk=1 da=0 db=1 sel=1  qa=0 qb=1  q=1
//   t=60  clk=0 da=1 db=0 sel=1  qa=0 qb=1  q=1
//   t=65  clk=1 da=1 db=0 sel=1  qa=1 qb=0  q=0
//   t=70  clk=0 da=1 db=0 sel=1  qa=1 qb=0  q=0
//   t=75  clk=1 da=1 db=0 sel=1  qa=1 qb=0  q=0
//   t=80  clk=0 da=0 db=0 sel=0  qa=1 qb=0  q=1
//   t=85  clk=1 da=0 db=0 sel=0  qa=0 qb=0  q=0
//   t=90  clk=0 da=0 db=1 sel=0  qa=0 qb=0  q=0
//   t=95  clk=1 da=0 db=1 sel=0  qa=0 qb=1  q=0
//   t=100  clk=0 da=1 db=1 sel=0  qa=0 qb=1  q=0
//   t=105  clk=1 da=1 db=1 sel=0  qa=1 qb=1  q=1
//   t=110  clk=0 da=1 db=1 sel=0  qa=1 qb=1  q=1
//   t=115  clk=1 da=1 db=1 sel=0  qa=1 qb=1  q=1
//   ** Note: $stop    : dff_sel_tb.v(28)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module dff_sel_tb at dff_sel_tb.v line 28
//
// 觀察重點：sel=0 時 q 跟著 qa，sel=1 時 q 跟著 qb；sel 是直接進多工器、不經過正反器，所以 sel 一變 q 立刻變


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog dff.v mux2_1.v dff_sel.v dff_sel_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.dff_sel_tb      Simulate > Start Simulation → work → dff_sel_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 dff_sel_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 dff.v、mux2_1.v、dff_sel.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, dff_sel_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
