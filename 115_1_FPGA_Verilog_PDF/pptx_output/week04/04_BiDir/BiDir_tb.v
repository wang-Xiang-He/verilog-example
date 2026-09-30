`timescale 1ns/1ps

// =====================================================================
// BiDir_tb：testbench 扮演「外部裝置」，也用三態方式驅動同一條接腳
// =====================================================================
module BiDir_tb;
    reg  data, enable_in_out;
    reg  ext_data, ext_en;          // 外部裝置要送的值、外部是否輸出
    wire data_in;
    wire pin;                       // 接到 inout 的一定要是 wire

    // 外部裝置的三態緩衝器
    assign pin = ext_en ? ext_data : 1'bz;

    BiDir uut (.data(data), .enable_in_out(enable_in_out),
               .data_in(data_in), .tri_inout(pin));

    initial begin
        $monitor("t=%0d  en=%b data=%b | ext_en=%b ext_data=%b  ->  pin=%b data_in=%b",
                 $time, enable_in_out, data, ext_en, ext_data, pin, data_in);
        // 1. 本模組輸出，外部放開
        enable_in_out = 1; data = 0; ext_en = 0; ext_data = 0; #10;
        data = 1; #10;
        // 2. 雙方都放開 → 接腳沒人驅動 = z
        enable_in_out = 0; #10;
        // 3. 本模組放開，外部輸出 → 本模組從 data_in 讀進來
        ext_en = 1; ext_data = 0; #10;
        ext_data = 1; #10;
        // 4. 錯誤示範：雙方同時輸出不同值 → x
        enable_in_out = 1; data = 0; #10;
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  en=1 data=0 | ext_en=0 ext_data=0  ->  pin=0 data_in=0
//   t=10  en=1 data=1 | ext_en=0 ext_data=0  ->  pin=1 data_in=1
//   t=20  en=0 data=1 | ext_en=0 ext_data=0  ->  pin=z data_in=z
//   t=30  en=0 data=1 | ext_en=1 ext_data=0  ->  pin=0 data_in=0
//   t=40  en=0 data=1 | ext_en=1 ext_data=1  ->  pin=1 data_in=1
//   t=50  en=1 data=0 | ext_en=1 ext_data=1  ->  pin=x data_in=x
//   ** Note: $stop    : BiDir_tb.v(31)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module BiDir_tb at BiDir_tb.v line 31
//
// 觀察重點：en=0 且外部也不輸出時接腳是 z（沒人驅動）；雙方同時輸出不同值時變成 x（打架），實際電路會短路


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog BiDir.v BiDir_tb.v                  Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.BiDir_tb        Simulate > Start Simulation → work → BiDir_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 BiDir_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 BiDir.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, BiDir_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
