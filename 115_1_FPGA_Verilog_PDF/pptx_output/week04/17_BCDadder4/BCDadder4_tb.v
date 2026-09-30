`timescale 1ns/1ps

// =====================================================================
// BCDadder4_tb：先看幾筆代表性的例子，再把所有合法 BCD 輸入跑一遍自動檢查
//   講義第 53 頁的測試平台用 9 位元計數器 data 把 {Cin, A, B} 全部跑一遍（512 筆），
//   其中 A、B 為 10~15 的組合不是合法 BCD，輸出沒有意義；這裡只檢查 A、B = 0~9
// =====================================================================
module BCDadder4_tb;
    wire [3:0] S;
    wire       Cout;
    reg        Cin;
    reg  [3:0] A, B;
    integer    i, j, k, errors, exp_sum;

    BCDadder4 uut (.S(S), .Cout(Cout), .Cin(Cin), .A(A), .B(B));

    task show;
        begin
            #10 $display("A=%0d B=%0d Cin=%b  ->  bin sum=%b(%0d) F=%b  ->  BCD: Cout=%b S=%b  (= %0d%0d)",
                         A, B, Cin, {uut.C4, uut.S_tmp}, {uut.C4, uut.S_tmp}, uut.F,
                         Cout, S, Cout, S);
        end
    endtask

    initial begin
        A = 4'd3; B = 4'd4; Cin = 0; show;   // 7：不用修正
        A = 4'd5; B = 4'd5; Cin = 0; show;   // 10 (1010)：S3·S1 = 1 → 修正
        A = 4'd7; B = 4'd6; Cin = 0; show;   // 13 (1101)：S3·S2 = 1 → 修正
        A = 4'd9; B = 4'd8; Cin = 0; show;   // 17：C4 = 1 → 修正
        A = 4'd9; B = 4'd9; Cin = 1; show;   // 19：最大值

        // 自動檢查：A、B = 0~9，Cin = 0/1，共 200 種
        errors = 0;
        for (k = 0; k < 2; k = k + 1)
            for (i = 0; i < 10; i = i + 1)
                for (j = 0; j < 10; j = j + 1) begin
                    Cin = k; A = i; B = j;
                    #1;
                    exp_sum = i + j + k;
                    if (Cout * 10 + S != exp_sum)
                        errors = errors + 1;
                end
        $display("check all BCD inputs (200 cases): errors = %0d", errors);
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   A=3 B=4 Cin=0  ->  bin sum=00111(7) F=0  ->  BCD: Cout=0 S=0111  (= 07)
//   A=5 B=5 Cin=0  ->  bin sum=01010(10) F=1  ->  BCD: Cout=1 S=0000  (= 10)
//   A=7 B=6 Cin=0  ->  bin sum=01101(13) F=1  ->  BCD: Cout=1 S=0011  (= 13)
//   A=9 B=8 Cin=0  ->  bin sum=10001(17) F=1  ->  BCD: Cout=1 S=0111  (= 17)
//   A=9 B=9 Cin=1  ->  bin sum=10011(19) F=1  ->  BCD: Cout=1 S=1001  (= 19)
//   check all BCD inputs (200 cases): errors = 0
//   ** Note: $stop    : BCDadder4_tb.v(44)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module BCDadder4_tb at BCDadder4_tb.v line 44
//
// 觀察重點：二進位和 > 9 時 F=1，加 6 修正（例如 5+5=1010 → 加 0110 → 1_0000 = 十進位 10）；200 種合法 BCD 輸入全部檢查 errors = 0


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog adder4.v BCDadder4.v BCDadder4_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.BCDadder4_tb    Simulate > Start Simulation → work → BCDadder4_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 BCDadder4_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 adder4.v、BCDadder4.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, BCDadder4_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
