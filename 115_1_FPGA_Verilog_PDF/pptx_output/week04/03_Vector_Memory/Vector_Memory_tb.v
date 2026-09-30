`timescale 1ns/1ps

// =====================================================================
// Vector_Memory_tb：向量、陣列、記憶體、位元選取、部分選取（講義第 9~12 頁）
//   只有 testbench，沒有電路本體；用 $display 把每一步的結果印出來
// =====================================================================
module Vector_Memory_tb;
    // ---------- 向量（Vector）：[MSB:LSB] 寫在名稱前面 ----------
    reg  [31:0] Result;            // 1 個 32 位元的 reg
    wire [15:0] bus;               // 1 個 16 位元的 wire
    //   講義第 9 頁寫 wire bus [15:0]; 與 reg Result [31:0];
    //   [15:0] 寫在名稱「後面」其實是宣告陣列（16 條 1 位元的線），不是向量，這裡改正
    wire        even;

    assign even = ~Result[0];          // 位元選取：Result 第 0 位元取反
    assign bus[15:0] = Result[15:0];   // 部分選取：Result 的第 15~0 位元

    // ---------- 記憶體（Memory）= reg 陣列（講義第 10、11 頁）----------
    //   reg [每個元素的位元數] 名稱 [元素個數]
    reg          Bit1, Bit2;
    reg          Memory1Bit  [1023:0];   // 1024 個 1 位元
    reg  [7:0]   Byte1, Byte2;
    reg  [7:0]   Memory1Byte [1023:0];   // 1024 個 8 位元（1 KB）

    // ---------- 位元選取 / 部分選取（講義第 12 頁）----------
    reg  [7:0]   a, b, c;

    initial begin
        // (1) 向量
        Result = 32'h1234_ABCD;
        #1;   // 等 assign 更新
        $display("(1) Result = %h", Result);
        $display("    bus  = Result[15:0] = %h", bus);
        $display("    even = ~Result[0]   = %b   (Result[0] = %b)", even, Result[0]);

        // (2) 1 位元記憶體：讀出第 321 個元素
        Memory1Bit[321] = 1'b1;
        Bit1 = Memory1Bit[321];
        $display("(2) Memory1Bit[321] = %b  ->  Bit1 = %b", Memory1Bit[321], Bit1);

        // (3) 8 位元記憶體：寫入第 586 個元素
        Byte1 = 8'hA5;
        Memory1Byte[586] = Byte1;
        $display("(3) Memory1Byte[586] = Byte1 = %b", Memory1Byte[586]);

        // (4) 取出記憶體某個元素的某一位元：要分兩步
        //     Verilog-1995 不能寫 Memory1Byte[125][4]，要先讀到 Byte2 再取位元
        Memory1Byte[125] = 8'b0001_0000;
        Byte2 = Memory1Byte[125];
        Bit2  = Byte2[4];
        $display("(4) Byte2 = Memory1Byte[125] = %b  ->  Bit2 = Byte2[4] = %b", Byte2, Bit2);
        //     Verilog-2001 起可以直接寫成一行：
        $display("    Verilog-2001: Memory1Byte[125][4] = %b", Memory1Byte[125][4]);

        // (5) 沒寫入過的記憶體元素是 x
        $display("(5) Memory1Byte[0] = %b  (never written)", Memory1Byte[0]);

        // (6) 位元選取與部分選取的 AND 運算
        a = 8'b1100_1010;
        b = 8'b1010_0110;
        c = 8'b0;
        c[0]   = a[0] & b[0];          // 位元選取：只算第 0 位元
        $display("(6) a=%b b=%b", a, b);
        $display("    c[0]   = a[0] & b[0]     -> c = %b", c);
        c[7:0] = a[7:0] & b[7:0];      // 部分選取：8 個位元一起算
        $display("    c[7:0] = a[7:0] & b[7:0] -> c = %b", c);
        c[7:4] = 4'b0000;              // 只改高 4 位元，低 4 位元不動
        $display("    c[7:4] = 4'b0000         -> c = %b", c);

        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   (1) Result = 1234abcd
//       bus  = Result[15:0] = abcd
//       even = ~Result[0]   = 0   (Result[0] = 1)
//   (2) Memory1Bit[321] = 1  ->  Bit1 = 1
//   (3) Memory1Byte[586] = Byte1 = 10100101
//   (4) Byte2 = Memory1Byte[125] = 00010000  ->  Bit2 = Byte2[4] = 1
//       Verilog-2001: Memory1Byte[125][4] = 1
//   (5) Memory1Byte[0] = xxxxxxxx  (never written)
//   (6) a=11001010 b=10100110
//       c[0]   = a[0] & b[0]     -> c = 00000000
//       c[7:0] = a[7:0] & b[7:0] -> c = 10000010
//       c[7:4] = 4'b0000         -> c = 00000010
//   ** Note: $stop    : Vector_Memory_tb.v(70)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Vector_Memory_tb at Vector_Memory_tb.v line 70
//
// 觀察重點：記憶體要先整個元素讀出來再取位元；沒寫入過的元素是 x；c[7:4] 部分選取只改高 4 位元


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Vector_Memory_tb.v                  Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Vector_Memory_tb Simulate > Start Simulation → work → Vector_Memory_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Vector_Memory_tb > Add Wave
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
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Vector_Memory_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
