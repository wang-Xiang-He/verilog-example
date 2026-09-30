`timescale 1ns/1ps

// =====================================================================
// TwosComp_tb：先測講義上的幾個值，再把 0~255 全部跑一遍和 -In_Data 比對
// =====================================================================
module TwosComp_tb;
    reg  [7:0] In_Data;
    wire [7:0] Out_Data;
    integer    k, errors;

    TwosComp uut (.In_Data(In_Data), .Out_Data(Out_Data));

    task show;
        begin
            #10 $display("In_Data=%b  ->  Out_Data=%b   (1's+1 = %b)",
                         In_Data, Out_Data, ~In_Data + 8'd1);
        end
    endtask

    initial begin
        In_Data = 8'b1101_0011; show;   // 講義第 37 頁的三個例子
        In_Data = 8'b1101_0010; show;
        In_Data = 8'b0101_0000; show;
        In_Data = 8'b1000_0000; show;
        In_Data = 8'b0000_0001; show;
        In_Data = 8'b0000_0000; show;

        // 自動檢查：所有 256 種輸入都要等於 -In_Data（也就是 ~In_Data + 1）
        errors = 0;
        for (k = 0; k < 256; k = k + 1) begin
            In_Data = k;
            #1;
            if (Out_Data !== (~In_Data + 8'd1))
                errors = errors + 1;
        end
        $display("check 0~255: errors = %0d", errors);
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   In_Data=11010011  ->  Out_Data=00101101   (1's+1 = 00101101)
//   In_Data=11010010  ->  Out_Data=00101110   (1's+1 = 00101110)
//   In_Data=01010000  ->  Out_Data=10110000   (1's+1 = 10110000)
//   In_Data=10000000  ->  Out_Data=10000000   (1's+1 = 10000000)
//   In_Data=00000001  ->  Out_Data=11111111   (1's+1 = 11111111)
//   In_Data=00000000  ->  Out_Data=00000000   (1's+1 = 00000000)
//   check 0~255: errors = 0
//   ** Note: $stop    : TwosComp_tb.v(37)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module TwosComp_tb at TwosComp_tb.v line 37
//
// 觀察重點：casex 的結果和「1 的補數 + 1」完全相同，256 種輸入全部檢查 errors = 0


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog TwosComp.v TwosComp_tb.v            Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.TwosComp_tb     Simulate > Start Simulation → work → TwosComp_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 TwosComp_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 TwosComp.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, TwosComp_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
