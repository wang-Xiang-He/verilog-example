`timescale 1ns/1ps

// =====================================================================
// Mux2to1_tb：4 種 2 對 1 多工器寫法一起測
//   (1) Select、a、b 跑遍 0 / 1 的 8 種組合 → 4 種寫法結果一樣
//   (2) Select 給 x、z（講義第 34、36 頁波形中 Select 變成不確定值的那段）→ 4 種寫法不一樣
// =====================================================================
module Mux2to1_tb;
    reg  a, b, Select;
    wire Out1, Out2, Out3, Out4;
    integer k;

    Mux2to1_1 u1 (.a(a), .b(b), .Select(Select), .Out(Out1));
    Mux2to1_2 u2 (.a(a), .b(b), .Select(Select), .Out(Out2));
    Mux2to1_3 u3 (.a(a), .b(b), .Select(Select), .Out(Out3));
    Mux2to1_4 u4 (.a(a), .b(b), .Select(Select), .Out(Out4));

    initial begin
        $display("            Select a b  |  _1(if) _2(?:) _3(if,x) _4(case)");
        for (k = 0; k < 8; k = k + 1) begin
            {Select, a, b} = k; #10 show;
        end
        Select = 1'bx; a = 1'b1; b = 1'b0; #10 show;   // a、b 不同
        Select = 1'bx; a = 1'b1; b = 1'b1; #10 show;   // a、b 相同
        Select = 1'bz; a = 1'b0; b = 1'b1; #10 show;
        $stop;
    end

    task show;
        $display("t=%3d       %b    %b %b  |     %b      %b       %b        %b",
                 $time, Select, a, b, Out1, Out2, Out3, Out4);
    endtask
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//               Select a b  |  _1(if) _2(?:) _3(if,x) _4(case)
//   t= 10       0    0 0  |     0      0       0        0
//   t= 20       0    0 1  |     1      1       1        1
//   t= 30       0    1 0  |     0      0       0        0
//   t= 40       0    1 1  |     1      1       1        1
//   t= 50       1    0 0  |     0      0       0        0
//   t= 60       1    0 1  |     0      0       0        0
//   t= 70       1    1 0  |     1      1       1        1
//   t= 80       1    1 1  |     1      1       1        1
//   t= 90       x    1 0  |     0      x       x        x
//   t=100       x    1 1  |     1      1       x        x
//   t=110       z    0 1  |     1      x       x        x
//   ** Note: $stop    : Mux2to1_tb.v(26)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Mux2to1_tb at Mux2to1_tb.v line 26
//
// 觀察重點：Select 是 0 / 1 時 4 種寫法完全一樣；Select = x 時 _1 把 x 當成「不成立」輸出 b，_2 在 a、b 相同時輸出那個值、不同時輸出 x，_3、_4 一律輸出 x


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Mux2to1_1.v Mux2to1_2.v Mux2to1_3.v Mux2to1_4.v Mux2to1_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Mux2to1_tb      Simulate > Start Simulation → work → Mux2to1_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Mux2to1_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Mux2to1_1.v、Mux2to1_2.v、Mux2to1_3.v、Mux2to1_4.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Mux2to1_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
