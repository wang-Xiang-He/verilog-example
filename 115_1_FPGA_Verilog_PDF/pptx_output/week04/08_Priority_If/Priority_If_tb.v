`timescale 1ns/1ps

// =====================================================================
// Priority_If_tb：XYZ 從 000 跑到 111，比較兩種寫法的輸出是否一樣
// =====================================================================
module Priority_If_tb;
    reg        X, Y, Z;
    reg  [3:0] Result1, Result2, Result3, Result4;
    wire [3:0] Out_a, Out_b;
    integer    k;

    Prio_IfElse  u_a (.X(X), .Y(Y), .Z(Z), .Result1(Result1), .Result2(Result2),
                      .Result3(Result3), .Result4(Result4), .Out(Out_a));
    Prio_MultiIf u_b (.X(X), .Y(Y), .Z(Z), .Result1(Result1), .Result2(Result2),
                      .Result3(Result3), .Result4(Result4), .Out(Out_b));

    initial begin
        // 用 1~4 代表 Result1~4，輸出是幾就知道選到哪一個
        Result1 = 4'd1; Result2 = 4'd2; Result3 = 4'd3; Result4 = 4'd4;
        for (k = 0; k < 8; k = k + 1) begin
            {X, Y, Z} = k;
            #10;
            $display("X=%b Y=%b Z=%b  ->  if-else: Result%0d   multi-if: Result%0d   %s",
                     X, Y, Z, Out_a, Out_b, (Out_a == Out_b) ? "same" : "DIFFERENT!");
        end
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   X=0 Y=0 Z=0  ->  if-else: Result1   multi-if: Result1         same
//   X=0 Y=0 Z=1  ->  if-else: Result4   multi-if: Result4         same
//   X=0 Y=1 Z=0  ->  if-else: Result3   multi-if: Result3         same
//   X=0 Y=1 Z=1  ->  if-else: Result4   multi-if: Result4         same
//   X=1 Y=0 Z=0  ->  if-else: Result2   multi-if: Result2         same
//   X=1 Y=0 Z=1  ->  if-else: Result4   multi-if: Result4         same
//   X=1 Y=1 Z=0  ->  if-else: Result3   multi-if: Result3         same
//   X=1 Y=1 Z=1  ->  if-else: Result4   multi-if: Result4         same
//   ** Note: $stop    : Priority_If_tb.v(26)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Priority_If_tb at Priority_If_tb.v line 26
//
// 觀察重點：巢狀 if...else 和「預設值 + 多個 if」兩種寫法結果完全相同，Z 優先權最高


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Prio_IfElse.v Prio_MultiIf.v Priority_If_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Priority_If_tb  Simulate > Start Simulation → work → Priority_If_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Priority_If_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Prio_IfElse.v、Prio_MultiIf.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Priority_If_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
