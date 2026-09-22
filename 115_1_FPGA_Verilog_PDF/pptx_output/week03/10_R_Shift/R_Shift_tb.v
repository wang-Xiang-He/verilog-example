`timescale 1ns/1ps

module R_Shift_tb;
    reg  [7:0] dividend;
    reg  [2:0] amount;
    wire [7:0] quotient;
    integer    i;

    R_Shift uut (.dividend(dividend), .amount(amount), .quotient(quotient));

    initial begin
        $monitor("t=%0d  dividend=%b(%0d) >> amount=%0d  ->  quotient=%b(%0d)",
                 $time, dividend, dividend, amount, quotient, quotient);
        dividend = 8'b1111_1111;                   // 講義第 66 頁用的值
        for (i = 0; i < 8; i = i + 1) begin
            amount = i; #10;
        end
        dividend = 8'd100; amount = 2; #10;        // 100 / 4 = 25
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  dividend=11111111(255) >> amount=0  ->  quotient=11111111(255)
//   t=10  dividend=11111111(255) >> amount=1  ->  quotient=01111111(127)
//   t=20  dividend=11111111(255) >> amount=2  ->  quotient=00111111(63)
//   t=30  dividend=11111111(255) >> amount=3  ->  quotient=00011111(31)
//   t=40  dividend=11111111(255) >> amount=4  ->  quotient=00001111(15)
//   t=50  dividend=11111111(255) >> amount=5  ->  quotient=00000111(7)
//   t=60  dividend=11111111(255) >> amount=6  ->  quotient=00000011(3)
//   t=70  dividend=11111111(255) >> amount=7  ->  quotient=00000001(1)
//   t=80  dividend=01100100(100) >> amount=2  ->  quotient=00011001(25)
//   ** Note: $stop    : R_Shift_tb.v(19)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module R_Shift_tb at R_Shift_tb.v line 19


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog R_Shift.v R_Shift_tb.v              Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.R_Shift_tb      Simulate > Start Simulation → work → R_Shift_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 R_Shift_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 R_Shift.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, R_Shift_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
