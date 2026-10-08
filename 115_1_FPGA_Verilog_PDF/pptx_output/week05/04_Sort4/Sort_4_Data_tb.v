`timescale 1ns/1ps

// =====================================================================
// Sort_4_Data_tb：先看幾筆例子，再把 4 個 4 位元輸入的 65536 種組合全部檢查
// =====================================================================
module Sort_4_Data_tb;
    reg  [3:0] a, b, c, d;
    wire [3:0] ra, rb, rc, rd;
    integer    k, errors;

    Sort_4_Data uut (.a(a), .b(b), .c(c), .d(d), .ra(ra), .rb(rb), .rc(rc), .rd(rd));

    task show;
        begin
            #10 $display("(a,b,c,d) = (%0d,%0d,%0d,%0d)  ->  (ra,rb,rc,rd) = (%0d,%0d,%0d,%0d)",
                         a, b, c, d, ra, rb, rc, rd);
        end
    endtask

    initial begin
        {a, b, c, d} = {4'd4, 4'd3, 4'd2, 4'd1};  show;   // 講義第 17 頁波形的兩筆
        {a, b, c, d} = {4'd3, 4'd1, 4'd4, 4'd2};  show;
        {a, b, c, d} = {4'd15, 4'd0, 4'd9, 4'd9}; show;   // 有重複的值
        {a, b, c, d} = {4'd1, 4'd2, 4'd3, 4'd4};  show;   // 本來就排好

        // 自動檢查：輸出要由小到大，而且 4 個數的總和不變
        errors = 0;
        for (k = 0; k < 65536; k = k + 1) begin
            {a, b, c, d} = k;
            #1;
            if (!(ra <= rb && rb <= rc && rc <= rd) || (ra + rb + rc + rd) != (a + b + c + d))
                errors = errors + 1;
        end
        $display("check all 65536 inputs: errors = %0d", errors);
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   (a,b,c,d) = (4,3,2,1)  ->  (ra,rb,rc,rd) = (1,2,3,4)
//   (a,b,c,d) = (3,1,4,2)  ->  (ra,rb,rc,rd) = (1,2,3,4)
//   (a,b,c,d) = (15,0,9,9)  ->  (ra,rb,rc,rd) = (0,9,9,15)
//   (a,b,c,d) = (1,2,3,4)  ->  (ra,rb,rc,rd) = (1,2,3,4)
//   check all 65536 inputs: errors = 0
//   ** Note: $stop    : Sort_4_Data_tb.v(35)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Sort_4_Data_tb at Sort_4_Data_tb.v line 35
//
// 觀察重點：輸出一律由小到大；重複的值也能正確排序；65536 種輸入全部檢查 errors = 0


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Sort_4_Data.v Sort_4_Data_tb.v      Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Sort_4_Data_tb  Simulate > Start Simulation → work → Sort_4_Data_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Sort_4_Data_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Sort_4_Data.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Sort_4_Data_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
