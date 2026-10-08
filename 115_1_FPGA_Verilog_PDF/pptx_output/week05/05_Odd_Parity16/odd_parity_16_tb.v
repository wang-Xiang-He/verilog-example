`timescale 1ns/1ps

// =====================================================================
// odd_parity_16_tb：講義第 21 頁的測試資料（和 02_Even_Parity16 相同的 7 筆）
// =====================================================================
module odd_parity_16_tb;
    reg  [15:0] Din;
    wire        Pout;

    odd_parity_16 uut (.Din(Din), .Pout(Pout));

    initial begin
        $monitor("t=%0d  Din=%h (%b)  ->  High=%b Low=%b  Pout=%b",
                 $time, Din, Din, uut.High, uut.Low, Pout);
        #0  Din = 16'b0;
        #10 Din = 16'h0a0a;
        #10 Din = 16'h24f5;
        #10 Din = 16'had12;
        #10 Din = 16'h8976;
        #10 Din = 16'h4536;
        #10 Din = 16'ha123;
        #10 $stop;              // 講義沒寫結束條件
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  Din=0000 (0000000000000000)  ->  High=1 Low=1  Pout=1
//   t=10  Din=0a0a (0000101000001010)  ->  High=1 Low=1  Pout=1
//   t=20  Din=24f5 (0010010011110101)  ->  High=1 Low=1  Pout=1
//   t=30  Din=ad12 (1010110100010010)  ->  High=0 Low=1  Pout=0
//   t=40  Din=8976 (1000100101110110)  ->  High=0 Low=0  Pout=1
//   t=50  Din=4536 (0100010100110110)  ->  High=0 Low=1  Pout=0
//   t=60  Din=a123 (1010000100100011)  ->  High=0 Low=0  Pout=1
//   ** Note: $stop    : odd_parity_16_tb.v(22)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module odd_parity_16_tb at odd_parity_16_tb.v line 22
//
// 觀察重點：每一筆的 Pout 都和 02_Even_Parity16 剛好相反（奇同位 = 偶同位反相）


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog odd_parity_16.v odd_parity_16_tb.v  Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.odd_parity_16_tb Simulate > Start Simulation → work → odd_parity_16_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 odd_parity_16_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 odd_parity_16.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, odd_parity_16_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
