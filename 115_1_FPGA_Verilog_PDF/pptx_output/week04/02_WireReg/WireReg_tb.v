`timescale 1ns/1ps

// =====================================================================
// WireReg_tb：reg（always）與 wire（assign）兩種寫法的結果比較
// =====================================================================
module WireReg_tb;
    reg  [3:0] a, b;
    wire [3:0] z_reg, z_wire;
    wire       zero;

    Add_Reg     u_reg  (.a(a), .b(b), .z(z_reg));
    Add_Wire    u_wire (.a(a), .b(b), .z(z_wire));
    Zero_Detect u_zero (.sum(z_reg), .zero(zero));   // 把加法結果接去判斷是否為 0

    initial begin
        $monitor("t=%0d  a=%0d b=%0d  ->  z_reg=%0d z_wire=%0d  zero=%b",
                 $time, a, b, z_reg, z_wire, zero);
        a = 4'd3;  b = 4'd4;  #10;
        a = 4'd0;  b = 4'd0;  #10;
        a = 4'd9;  b = 4'd6;  #10;
        a = 4'd9;  b = 4'd7;  #10;   // 9 + 7 = 16，4 位元放不下 → 0
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  a=3 b=4  ->  z_reg=7 z_wire=7  zero=0
//   t=10  a=0 b=0  ->  z_reg=0 z_wire=0  zero=1
//   t=20  a=9 b=6  ->  z_reg=15 z_wire=15  zero=0
//   t=30  a=9 b=7  ->  z_reg=0 z_wire=0  zero=1
//   ** Note: $stop    : WireReg_tb.v(22)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module WireReg_tb at WireReg_tb.v line 22
//
// 觀察重點：always 寫法（z_reg）和 assign 寫法（z_wire）結果完全一樣；t=30 時 9+7=16 溢位成 0，所以 zero 也變成 1


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Zero_Detect.v Add_Reg.v Add_Wire.v WireReg_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.WireReg_tb      Simulate > Start Simulation → work → WireReg_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 WireReg_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Zero_Detect.v、Add_Reg.v、Add_Wire.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, WireReg_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
