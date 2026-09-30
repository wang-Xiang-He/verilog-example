`timescale 1ns/1ps

// =====================================================================
// Case_tb：分三段測試 Case_Prio、Mux_Case、Casex_Prio
// =====================================================================
module Case_tb;
    // Case_Prio
    reg  [1:0] u, v, w;
    wire [2:0] Out_p;
    // Mux_Case
    reg  [1:0] select;
    wire [3:0] Out_m;
    // Casex_Prio
    reg        X, Y, Z;
    wire [3:0] Value;
    integer    k;

    Case_Prio  u_p (.u(u), .v(v), .w(w), .Out(Out_p));
    Mux_Case   u_m (.select(select), .in1(4'hA), .in2(4'hB), .in3(4'hC), .in4(4'hD),
                    .Out(Out_m));
    Casex_Prio u_x (.X(X), .Y(Y), .Z(Z), .Result1(4'd1), .Result2(4'd2),
                    .Result3(4'd3), .Result4(4'd4), .Value(Value));

    initial begin
        $display("--- (1) Case_Prio: case (2'b11) ---");
        u = 2'b11; v = 2'b11; w = 2'b11; #10 $display("u=%b v=%b w=%b  ->  Out=%b", u, v, w, Out_p);
        u = 2'b01; v = 2'b11; w = 2'b11; #10 $display("u=%b v=%b w=%b  ->  Out=%b", u, v, w, Out_p);
        u = 2'b01; v = 2'b10; w = 2'b11; #10 $display("u=%b v=%b w=%b  ->  Out=%b", u, v, w, Out_p);
        u = 2'b00; v = 2'b00; w = 2'b00; #10 $display("u=%b v=%b w=%b  ->  Out=%b", u, v, w, Out_p);

        $display("--- (2) Mux_Case: in1=A in2=B in3=C in4=D ---");
        for (k = 0; k < 4; k = k + 1) begin
            select = k;
            #10 $display("select=%b  ->  Out=%h", select, Out_m);
        end

        $display("--- (3) Casex_Prio: 1xx / x1x / xx1 ---");
        for (k = 0; k < 8; k = k + 1) begin
            {X, Y, Z} = k;
            #10 $display("XYZ=%b%b%b  ->  Value=Result%0d", X, Y, Z, Value);
        end
        $stop;
    end
endmodule


// =====================================================================
// 【預期輸出】ModelSim 的 Transcript 視窗（每行前面會多一個 # 號）
// =====================================================================
//   --- (1) Case_Prio: case (2'b11) ---
//   u=11 v=11 w=11  ->  Out=001
//   u=01 v=11 w=11  ->  Out=010
//   u=01 v=10 w=11  ->  Out=100
//   u=00 v=00 w=00  ->  Out=000
//   --- (2) Mux_Case: in1=A in2=B in3=C in4=D ---
//   select=00  ->  Out=a
//   select=01  ->  Out=b
//   select=10  ->  Out=c
//   select=11  ->  Out=d
//   --- (3) Casex_Prio: 1xx / x1x / xx1 ---
//   XYZ=000  ->  Value=Result4
//   XYZ=001  ->  Value=Result3
//   XYZ=010  ->  Value=Result2
//   XYZ=011  ->  Value=Result2
//   XYZ=100  ->  Value=Result1
//   XYZ=101  ->  Value=Result1
//   XYZ=110  ->  Value=Result1
//   XYZ=111  ->  Value=Result1
//   ** Note: $stop    : Case_tb.v(42)          <- 執行到 $stop，模擬暫停，波形保留
//   Break in Module Case_tb at Case_tb.v line 42
//
// 觀察重點：Case_Prio 取第一個等於 11 的變數；Mux_Case 各項互斥；Casex_Prio 多項同時符合時取最上面那一項（X 最優先）


// =====================================================================
// 【ModelSim 執行指令】
// =====================================================================
//   方法 A（一鍵）：Transcript 視窗先 cd 到本資料夾，再輸入  do run.do
//   方法 B（逐行輸入，和 run.do 內容相同）：
//     步驟          指令                                     選單操作
//     ------------------------------------------------------------------------------
//     0. 建工作庫   vlib work                                File > New > Library
//     1. 編譯       vlog Case_Prio.v Mux_Case.v Casex_Prio.v Case_tb.v Compile > Compile...（全選 .v 檔）
//     2. 載入模擬   vsim -voptargs=+acc work.Case_tb         Simulate > Start Simulation → work → Case_tb
//     3. 加波形     add wave -r /*                           sim 視窗右鍵 Case_tb > Add Wave
//     4. 執行       run -all                                 工具列 Run -All 按鈕
//     5. 結束模擬   quit -sim                                Simulate > End Simulation
//   -voptargs=+acc：保留所有訊號給波形視窗看；不加的話新版 ModelSim 會把訊號最佳化掉，
//                   Add Wave 可能看不到東西。若你的版本不認得這個參數，直接拿掉即可


// =====================================================================
// 【若要改用 EDA Playground】
// =====================================================================
//   design.sv    ← 依序貼上 Case_Prio.v、Mux_Case.v、Casex_Prio.v
//   testbench.sv ← 貼上本檔
//   並做兩個修改：
//     (1) 在 testbench 裡加  initial begin $dumpfile("dump.vcd"); $dumpvars(0, Case_tb); end
//     (2) 把 $stop 改成 $finish
//   程式碼其餘部分兩邊完全相同
