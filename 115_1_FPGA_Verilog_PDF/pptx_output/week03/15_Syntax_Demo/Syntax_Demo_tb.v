`timescale 1ns/1ps

// =====================================================================
// Syntax_Demo_tb：只有 testbench、沒有電路，用 $display 把講義的語法例子印出來
//   （印出的字串用英文，避免 ModelSim Transcript 顯示中文亂碼）
// =====================================================================
module Syntax_Demo_tb;
    reg [2:0]  in;
    reg [15:0] Out1;
    reg [9:0]  Out2;
    reg [8:0]  Out3;
    reg [7:0]  Out4;
    reg [31:0] U;
    reg [11:0] W;
    reg [7:0]  Q;
    reg [3:0]  data1;
    reg [8*18-1:0] stringvar;   // 18 個字元 × 8 位元 = 144 位元的暫存器，用來存字串

    initial begin
        // ---------- 數值（Numbers，第 12~14 頁） ----------
        // 定長度數字格式：<位元數>'<進位制><數值>，h=十六進位 d=十進位 o=八進位 b=二進位
        in = 3'd1;                              // 左移 1 次 = 乘以 2
        Out1 = 16'h89Ab     << in;              // 16 位元十六進位
        Out2 = 10'd128      << in;              // 10 位元十進位
        Out3 = 9'o377       << in;              // 9 位元八進位
        Out4 = 8'b10101010  << in;              // 8 位元二進位（最高位的 1 被擠掉）
        $display("16'h89Ab << 1     = %h (hex)", Out1);
        $display("10'd128 << 1      = %0d (dec)", Out2);
        $display("9'o377 << 1       = %o (oct)", Out3);
        $display("8'b10101010 << 1  = %b (bin)", Out4);

        // 不定長度：沒寫位元數 → 預設 32 位元；沒寫進位制 → 預設十進位
        U = 'h89Ab;
        $display("'h89Ab (unsized)  = %b (32 bits)", U);

        // -8'd79：負號放在最前面，存成 79 的 2 的補數
        Out4 = -8'd79;
        $display("-8'd79            = %b = %0d (as unsigned)", Out4, Out4);

        // ---------- 底線與問號（第 17 頁） ----------
        W = 12'b1010_1111_0101;                 // 底線只是方便閱讀，等於 12'b101011110101
        $display("12'b1010_1111_0101 = %b", W);
        Q = 8'b11??11??;                        // ? 在數值裡等於 z（高阻抗）
        $display("8'b11??11??       = %b  (? = z)", Q);

        // ---------- 字串（Strings，第 15 頁） ----------
        stringvar = "Hello Verilog HDL!";
        $display("stringvar         = %s", stringvar);

        // ---------- $display 與 $write（第 18、19 頁） ----------
        $display("Hello Prof. Lin");
        $display($time);                        // 顯示目前時間（預設十進位、固定寬度）
        data1 = 4'b0101;
        $display("The data is %b", data1);      // The data is 0101
        $write(4'b1111);                        // $write 不會自動換行
        $write(" ", 5'b10101);
        $writeh(" ", 5'b01111, "\n");           // $writeh = 預設用十六進位顯示
        // 講義顯示結果為：15 21 0F（實際數字前可能有空白，十六進位可能是小寫 0f）

        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   16'h89Ab << 1     = 1356 (hex)
//   10'd128 << 1      = 256 (dec)
//   9'o377 << 1       = 776 (oct)
//   8'b10101010 << 1  = 01010100 (bin)
//   'h89Ab (unsized)  = 00000000000000001000100110101011 (32 bits)
//   -8'd79            = 10110001 = 177 (as unsigned)
//   12'b1010_1111_0101 = 101011110101
//   8'b11??11??       = 11zz11zz  (? = z)
//   stringvar         = Hello Verilog HDL!
//   Hello Prof. Lin
//                      0
//   The data is 0101
//   15 21 0f
//   ** Note: $stop    : Syntax_Demo_tb.v(60)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Syntax_Demo_tb at Syntax_Demo_tb.v line 60
//
// 觀察重點：這個範例只有 testbench，vlog 只編譯 Syntax_Demo_tb.v 一個檔案；重點看 Transcript 的文字輸出，不需要看波形


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Syntax_Demo_tb.v                    Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Syntax_Demo_tb  Simulate > Start Simulation → work → Syntax_Demo_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Syntax_Demo_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 留空（本範例只有 testbench）
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Syntax_Demo_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
