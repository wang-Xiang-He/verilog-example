`timescale 1ns/1ps

// =====================================================================
// even16_fun_fun_tb：用和 02_Even_Parity16 相同的 7 筆資料，
//   再把 65536 種輸入全部和「直接寫 ^Din」的結果比對
// =====================================================================
module even16_fun_fun_tb;
    reg  [15:0] Din;
    wire        Pout;
    integer     k, errors;

    even16_fun_fun uut (.Din(Din), .Pout(Pout));

    task show (input [15:0] value);
        begin
            Din = value;
            #10 $display("Din=%h (%b)  ->  High=%b Low=%b  Pout=%b",
                         Din, Din, uut.High, uut.Low, Pout);
        end
    endtask

    initial begin
        show(16'h0000);
        show(16'h0a0a);
        show(16'h24f5);
        show(16'had12);
        show(16'h8976);
        show(16'h4536);
        show(16'ha123);

        errors = 0;
        for (k = 0; k < 65536; k = k + 1) begin
            Din = k;
            #1;
            if (Pout !== ^Din)
                errors = errors + 1;
        end
        $display("check all 65536 inputs against ^Din: errors = %0d", errors);
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   Din=0000 (0000000000000000)  ->  High=0 Low=0  Pout=0
//   Din=0a0a (0000101000001010)  ->  High=0 Low=0  Pout=0
//   Din=24f5 (0010010011110101)  ->  High=0 Low=0  Pout=0
//   Din=ad12 (1010110100010010)  ->  High=1 Low=0  Pout=1
//   Din=8976 (1000100101110110)  ->  High=1 Low=1  Pout=0
//   Din=4536 (0100010100110110)  ->  High=1 Low=0  Pout=1
//   Din=a123 (1010000100100011)  ->  High=1 Low=1  Pout=0
//   check all 65536 inputs against ^Din: errors = 0
//   ** Note: $stop    : even16_fun_fun_tb.v(39)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module even16_fun_fun_tb at even16_fun_fun_tb.v line 39
//
// 觀察重點：結果和 02_Even_Parity16 完全相同，也和直接寫 ^Din 相同（65536 種輸入 errors = 0）


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog even16_fun_fun.v even16_fun_fun_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.even16_fun_fun_tb Simulate > Start Simulation → work → even16_fun_fun_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 even16_fun_fun_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 even16_fun_fun.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, even16_fun_fun_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
