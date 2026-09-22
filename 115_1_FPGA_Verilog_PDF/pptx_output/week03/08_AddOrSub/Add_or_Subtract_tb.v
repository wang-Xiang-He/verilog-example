`timescale 1ns/1ps

module Add_or_Subtract_tb;
    reg        op;
    reg  [7:0] a, b;
    wire [7:0] s;

    Add_or_Subtract uut (.a(a), .b(b), .op(op), .s(s));

    initial begin
        // op = 1 → 加法（ADD）；op = 0 → 減法（SUB）
        $monitor("t=%0d  op=%b  a=%b(%0d) b=%b(%0d)  ->  s=%b(%0d)",
                 $time, op, a, a, b, b, s, s);
        op = 1; a = 8'b1111_1111; b = 8'b0000_0001; #10;  // 講義第 60 頁：ADD，255+1 溢位成 0
        op = 0; a = 8'b0011_1111; b = 8'b0000_0101; #10;  // 講義第 60 頁：SUB，63-5=58
        op = 1; a = 8'd100;       b = 8'd23;        #10;  // 100+23=123
        op = 0; a = 8'd3;         b = 8'd5;         #10;  // 3-5 = -2 → 8 位元 2 的補數 = 254
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  op=1  a=11111111(255) b=00000001(1)  ->  s=00000000(0)
//   t=10  op=0  a=00111111(63) b=00000101(5)  ->  s=00111010(58)
//   t=20  op=1  a=01100100(100) b=00010111(23)  ->  s=01111011(123)
//   t=30  op=0  a=00000011(3) b=00000101(5)  ->  s=11111110(254)
//   ** Note: $stop    : Add_or_Subtract_tb.v(18)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Add_or_Subtract_tb at Add_or_Subtract_tb.v line 18


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Add_or_Subtract.v Add_or_Subtract_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Add_or_Subtract_tb Simulate > Start Simulation → work → Add_or_Subtract_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Add_or_Subtract_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Add_or_Subtract.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Add_or_Subtract_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
