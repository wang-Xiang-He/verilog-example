`timescale 1ns/1ps

// =====================================================================
// DeMux1x4_By_DeMux1to2E_tb：用兩個 1 對 2 組成的 1 對 4 解多工器測試平台
//   (1) S1 S0 跑 00~11，D 給 1 再給 0
//   (2) 和 11_DeMux1x4 的布林方程式比對 32 種輸入（含 S1 / S0 / D 為 x 的情況不測）
// =====================================================================
module DeMux1x4_By_DeMux1to2E_tb;
    reg  D, S1, S0;
    wire Y0, Y1, Y2, Y3;
    wire [3:0] expect = {S1 & S0 & D, S1 & !S0 & D, !S1 & S0 & D, !S1 & !S0 & D};
    integer k, errors;

    DeMux1x4_By_DeMux1to2E uut (.S1(S1), .S0(S0), .D(D), .Y0(Y0), .Y1(Y1), .Y2(Y2), .Y3(Y3));

    initial begin
        $monitor("t=%0d  S1S0=%b%b D=%b  |  Not_S1=%b  ->  Y3..Y0=%b%b%b%b",
                 $time, S1, S0, D, uut.Not_S1, Y3, Y2, Y1, Y0);
        for (k = 0; k < 8; k = k + 1) begin
            {S1, S0} = k / 2;  D = ~k[0]; #10;
        end
        $monitoroff;
        errors = 0;
        for (k = 0; k < 8; k = k + 1) begin
            {S1, S0, D} = k; #1;
            if ({Y3, Y2, Y1, Y0} !== expect) errors = errors + 1;
        end
        $display("checked 8 inputs, errors = %0d", errors);
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=0  S1S0=00 D=1  |  Not_S1=1  ->  Y3..Y0=0001
//   t=10  S1S0=00 D=0  |  Not_S1=1  ->  Y3..Y0=0000
//   t=20  S1S0=01 D=1  |  Not_S1=1  ->  Y3..Y0=0010
//   t=30  S1S0=01 D=0  |  Not_S1=1  ->  Y3..Y0=0000
//   t=40  S1S0=10 D=1  |  Not_S1=0  ->  Y3..Y0=0100
//   t=50  S1S0=10 D=0  |  Not_S1=0  ->  Y3..Y0=0000
//   t=60  S1S0=11 D=1  |  Not_S1=0  ->  Y3..Y0=1000
//   t=70  S1S0=11 D=0  |  Not_S1=0  ->  Y3..Y0=0000
//   checked 8 inputs, errors = 0
//   ** Note: $stop    : DeMux1x4_By_DeMux1to2E_tb.v(29)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module DeMux1x4_By_DeMux1to2E_tb at DeMux1x4_By_DeMux1to2E_tb.v line 29
//
// 觀察重點：S1=0 時 Not_S1=1，上面那顆動作（D 出現在 Y0 或 Y1）；S1=1 時下面那顆動作（Y2 或 Y3）；結果和 11_DeMux1x4 相同


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog DeMux1x4_By_DeMux1to2E.v DeMux1x4_By_DeMux1to2E_tb.v Compile > Compile...（不要選 DeMux1to2E.v）
//     2. 載入模擬   vsim -voptargs=+acc work.DeMux1x4_By_DeMux1to2E_tb Simulate > Start Simulation → work → DeMux1x4_By_DeMux1to2E_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 DeMux1x4_By_DeMux1to2E_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 DeMux1x4_By_DeMux1to2E.v
//   另外新增一個檔案分頁，命名為 DeMux1to2E.v，貼上 DeMux1to2E.v 的內容
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, DeMux1x4_By_DeMux1to2E_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
