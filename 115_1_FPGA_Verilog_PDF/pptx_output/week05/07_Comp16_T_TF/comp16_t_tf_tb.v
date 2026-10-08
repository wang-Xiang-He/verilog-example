`timescale 1ns/1ps

// =====================================================================
// comp16_t_tf_tb：講義沒有列出測試平台，自行補上
//   先讓「不同的地方」依序落在 4 個 4 位元區段，再用 10000 筆亂數自動檢查
// =====================================================================
module comp16_t_tf_tb;
    reg  [15:0] A, B;
    wire [2:0]  Yout;
    reg  [2:0]  expected;
    integer     k, errors;

    comp16_t_tf uut (.A(A), .B(B), .Yout(Yout));

    task show (input [15:0] va, input [15:0] vb);
        begin
            A = va;
            B = vb;
            #10 $display("A=%h B=%h  ->  Yout=%b", A, B, Yout);
        end
    endtask

    initial begin
        show(16'h0000, 16'h0000);   // 相等
        show(16'haaaa, 16'haaaa);   // 相等
        show(16'h5000, 16'h1fff);   // 第 15~12 位元就分出大小（compare4_T）
        show(16'h1234, 16'h1934);   // 第 11~8  位元分出大小（compare4_F）
        show(16'h1254, 16'h1234);   // 第 7~4   位元分出大小（第 2 次 compare8 的 compare4_T）
        show(16'h1234, 16'h1235);   // 第 3~0   位元分出大小（第 2 次 compare8 的 compare4_F）

        errors = 0;
        for (k = 0; k < 10000; k = k + 1) begin
            A = $random;
            B = (k % 4 == 0) ? A : $random;         // 每 4 筆安排 1 筆相等
            #1;
            expected = (A > B) ? 3'b100 : (A == B) ? 3'b010 : 3'b001;
            if (Yout !== expected)
                errors = errors + 1;
        end
        $display("check 10000 random inputs: errors = %0d", errors);
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   A=0000 B=0000  ->  Yout=010
//   A=aaaa B=aaaa  ->  Yout=010
//   A=5000 B=1fff  ->  Yout=100
//   A=1234 B=1934  ->  Yout=001
//   A=1254 B=1234  ->  Yout=100
//   A=1234 B=1235  ->  Yout=001
//   check 10000 random inputs: errors = 0
//   ** Note: $stop    : comp16_t_tf_tb.v(41)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module comp16_t_tf_tb at comp16_t_tf_tb.v line 41
//
// 觀察重點：100 = A>B、010 = A=B、001 = A<B；由最高的 4 位元開始比，分出大小就不再往下比


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog comp16_t_tf.v comp16_t_tf_tb.v      Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.comp16_t_tf_tb  Simulate > Start Simulation → work → comp16_t_tf_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 comp16_t_tf_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 comp16_t_tf.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, comp16_t_tf_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
