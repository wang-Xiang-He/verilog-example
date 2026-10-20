`timescale 1ns/1ps

// =====================================================================
// Encoder2_3_tb：同時測試 Encoder2（assign）與 Encoder3（if ... else）
//   (1) 印出講義第 20、22 頁波形的兩組，以及每個輸入單獨為 1 的情況
//   (2) 自動檢查 256 種輸入，兩個編碼器的輸出要完全一樣
// =====================================================================
module Encoder2_3_tb;
    reg  a, b, c, d, e, f, g, h;
    wire [3:0] V2, V3;
    wire       N2, O2_2, O1_2, O0_2;
    wire       N3, O2_3, O1_3, O0_3;
    integer    k, errors;

    Encoder2 u2 (a, b, c, d, e, f, g, h, V2, N2, O2_2, O1_2, O0_2);    // 依順序連接
    Encoder3 u3 (.a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g), .h(h),
                 .Out_Vect(V3), .None_ON(N3), .Out2(O2_3), .Out1(O1_3), .Out0(O0_3));

    initial begin
        // ---------- (1) 印出來看 ----------
        $display("  h g f e d c b a  |  Encoder2: None_ON Out[2:0]  |  Encoder3: None_ON Out[2:0]");
        {h, g, f, e, d, c, b, a} = 8'b0000_0001; #10 show;     // 講義第 20 頁：a = 1 → 0000
        {h, g, f, e, d, c, b, a} = 8'b0000_0110; #10 show;     // 講義第 20 頁：b、c = 1 → 取 c
        {h, g, f, e, d, c, b, a} = 8'b0000_0000; #10 show;     // 全部是 0 → None_ON = 1
        for (k = 0; k < 8; k = k + 1) begin
            {h, g, f, e, d, c, b, a} = 8'b1 << k; #10 show;
        end
        {h, g, f, e, d, c, b, a} = 8'b1111_1111; #10 show;     // 全部是 1 → 取 h

        // ---------- (2) 256 種輸入自動檢查 ----------
        errors = 0;
        for (k = 0; k < 256; k = k + 1) begin
            {h, g, f, e, d, c, b, a} = k; #1;
            if (V2 !== V3 || {N2, O2_2, O1_2, O0_2} !== V3) errors = errors + 1;
        end
        $display("checked 256 inputs, errors = %0d", errors);
        $stop;
    end

    task show;
        $display("  %b %b %b %b %b %b %b %b  |      %b      %b%b%b         |      %b      %b%b%b",
                 h, g, f, e, d, c, b, a, N2, O2_2, O1_2, O0_2, N3, O2_3, O1_3, O0_3);
    endtask
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//     h g f e d c b a  |  Encoder2: None_ON Out[2:0]  |  Encoder3: None_ON Out[2:0]
//     0 0 0 0 0 0 0 1  |      0      000         |      0      000
//     0 0 0 0 0 1 1 0  |      0      010         |      0      010
//     0 0 0 0 0 0 0 0  |      1      000         |      1      000
//     0 0 0 0 0 0 0 1  |      0      000         |      0      000
//     0 0 0 0 0 0 1 0  |      0      001         |      0      001
//     0 0 0 0 0 1 0 0  |      0      010         |      0      010
//     0 0 0 0 1 0 0 0  |      0      011         |      0      011
//     0 0 0 1 0 0 0 0  |      0      100         |      0      100
//     0 0 1 0 0 0 0 0  |      0      101         |      0      101
//     0 1 0 0 0 0 0 0  |      0      110         |      0      110
//     1 0 0 0 0 0 0 0  |      0      111         |      0      111
//     1 1 1 1 1 1 1 1  |      0      111         |      0      111
//   checked 256 inputs, errors = 0
//   ** Note: $stop    : Encoder2_3_tb.v(37)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Encoder2_3_tb at Encoder2_3_tb.v line 37
//
// 觀察重點：兩種寫法每一行都一樣，256 種輸入檢查 errors = 0；a=1 → 000、b c=1 → 010（c 優先），和講義第 20、22 頁相同


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Encoder2.v Encoder3.v Encoder2_3_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Encoder2_3_tb   Simulate > Start Simulation → work → Encoder2_3_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Encoder2_3_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Encoder2.v、Encoder3.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Encoder2_3_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
