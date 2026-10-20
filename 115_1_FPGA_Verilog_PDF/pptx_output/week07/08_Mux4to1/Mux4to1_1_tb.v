`timescale 1ns/1ps

// =====================================================================
// Mux4to1_1_tb：4 對 1 多工器測試平台
//   (1) 資料固定 A B C D = 1 0 1 0 和 0 1 0 1，S1 S0 跑 00~11 → 看 Out 跟著哪一個
//   (2) 自動檢查 64 種輸入
// =====================================================================
module Mux4to1_1_tb;
    reg  D3, D2, D1, D0, S1, S0;        // D3~D0 接到模組的 D、C、B、A
    wire Out;
    wire [3:0] data = {D3, D2, D1, D0};
    integer k, errors;

    Mux4to1_1 uut (.A(D0), .B(D1), .C(D2), .D(D3), .S1(S1), .S0(S0), .Out(Out));

    initial begin
        $monitor("t=%0d  S1S0=%b%b  D C B A=%b %b %b %b  ->  Out=%b",
                 $time, S1, S0, D3, D2, D1, D0, Out);
        {D3, D2, D1, D0} = 4'b0101;
        {S1, S0} = 2'b00; #10;  {S1, S0} = 2'b01; #10;
        {S1, S0} = 2'b10; #10;  {S1, S0} = 2'b11; #10;
        {D3, D2, D1, D0} = 4'b1010;
        {S1, S0} = 2'b00; #10;  {S1, S0} = 2'b01; #10;
        {S1, S0} = 2'b10; #10;  {S1, S0} = 2'b11; #10;
        $monitoroff;
        // ---------- 64 種輸入自動檢查：Out 一定要等於被選到的那一個 ----------
        errors = 0;
        for (k = 0; k < 64; k = k + 1) begin
            {S1, S0, D3, D2, D1, D0} = k; #1;
            if (Out !== data[{S1, S0}]) errors = errors + 1;
        end
        $display("checked 64 inputs, errors = %0d", errors);
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  S1S0=00  D C B A=0 1 0 1  ->  Out=1
//   t=10  S1S0=01  D C B A=0 1 0 1  ->  Out=0
//   t=20  S1S0=10  D C B A=0 1 0 1  ->  Out=1
//   t=30  S1S0=11  D C B A=0 1 0 1  ->  Out=0
//   t=40  S1S0=00  D C B A=1 0 1 0  ->  Out=0
//   t=50  S1S0=01  D C B A=1 0 1 0  ->  Out=1
//   t=60  S1S0=10  D C B A=1 0 1 0  ->  Out=0
//   t=70  S1S0=11  D C B A=1 0 1 0  ->  Out=1
//   checked 64 inputs, errors = 0
//   ** Note: $stop    : Mux4to1_1_tb.v(33)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Mux4to1_1_tb at Mux4to1_1_tb.v line 33
//
// 觀察重點：S1S0=00 時 Out=A、01 時 Out=B、10 時 Out=C、11 時 Out=D；64 種輸入檢查 errors = 0


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Mux4to1_1.v Mux4to1_1_tb.v          Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Mux4to1_1_tb    Simulate > Start Simulation → work → Mux4to1_1_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Mux4to1_1_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Mux4to1_1.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Mux4to1_1_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
