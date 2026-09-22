`timescale 1ns/1ps

// =====================================================================
// Hierar_tb：同時測試 Top1（依順序）與 Top2（依名稱），兩者輸出應完全相同
// =====================================================================
module Hierar_tb;
    reg        Clock, Reset, Sel, Left_Rotate;
    reg  [7:0] a, b;
    wire [7:0] out1, out2;

    Top1 u_top1 (Clock, Reset, Sel, Left_Rotate, a, b, out1);
    Top2 u_top2 (.Clock(Clock), .Reset(Reset), .Sel(Sel), .Left_Rotate(Left_Rotate),
                 .a(a), .b(b), .out(out2));

    // 產生時脈：週期 10ns（每 5ns 反相一次）
    initial Clock = 0;
    always #5 Clock = ~Clock;

    // 在時脈負緣印出結果（避開正緣，數值已穩定）
    // 最後的 same / DIFF! 表示 Top1 和 Top2 的輸出是否相同（字串用英文，避免 Transcript 顯示亂碼）
    always @(negedge Clock)
        $display("t=%0d  Reset=%b Sel=%b Rot=%b  Reg_Out=%b  out1=%b  out2=%b  %s",
                 $time, Reset, Sel, Left_Rotate, u_top1.Reg_Out, out1, out2,
                 (out1 === out2) ? "same" : "DIFF!");
        // u_top1.Reg_Out：用階層式名稱直接看子模組內部訊號（只能用在模擬）

    initial begin
        a = 8'b1000_0001; b = 8'b0000_1111;
        Reset = 1; Sel = 1; Left_Rotate = 0;
        #12 Reset = 0;                 // 放開重置
        #20 Sel = 0;                   // 改選 b，觀察資料流過兩級暫存器
        #20 Sel = 1;                   // 再選回 a
        #20 Left_Rotate = 1;           // 開始向左旋轉
        #50 $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   t=10  Reset=1 Sel=1 Rot=0  Reg_Out=00000000  out1=00000000  out2=00000000   same
//   t=20  Reset=0 Sel=1 Rot=0  Reg_Out=10000001  out1=00000000  out2=00000000   same
//   t=30  Reset=0 Sel=1 Rot=0  Reg_Out=10000001  out1=10000001  out2=10000001   same
//   t=40  Reset=0 Sel=0 Rot=0  Reg_Out=00001111  out1=10000001  out2=10000001   same
//   t=50  Reset=0 Sel=0 Rot=0  Reg_Out=00001111  out1=00001111  out2=00001111   same
//   t=60  Reset=0 Sel=1 Rot=0  Reg_Out=10000001  out1=00001111  out2=00001111   same
//   t=70  Reset=0 Sel=1 Rot=0  Reg_Out=10000001  out1=10000001  out2=10000001   same
//   t=80  Reset=0 Sel=1 Rot=1  Reg_Out=10000001  out1=00000011  out2=00000011   same
//   t=90  Reset=0 Sel=1 Rot=1  Reg_Out=10000001  out1=00000110  out2=00000110   same
//   t=100  Reset=0 Sel=1 Rot=1  Reg_Out=10000001  out1=00001100  out2=00001100   same
//   t=110  Reset=0 Sel=1 Rot=1  Reg_Out=10000001  out1=00011000  out2=00011000   same
//   t=120  Reset=0 Sel=1 Rot=1  Reg_Out=10000001  out1=00110000  out2=00110000   same
//   ** Note: $stop    : Hierar_tb.v(34)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Hierar_tb at Hierar_tb.v line 34
//
// 觀察重點：Reg_Out 是第一級暫存器，out 是第二級：資料進去後要 2 個時脈才會出現在 out；Left_Rotate=1 後每個時脈向左轉 1 位元


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Mux.v Register8.v Rotate_Data.v Top1.v Top2.v Hierar_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Hierar_tb       Simulate > Start Simulation → work → Hierar_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Hierar_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Mux.v、Register8.v、Rotate_Data.v、Top1.v、Top2.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Hierar_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
