// Bidirectional_tb.v : 觀察 enable_in_out = 1 且 data_in = 1 時的訊號流動
`timescale 1ns/1ps
module Bidirectional_tb;
  reg  data, data_in, enable_in_out;
  wire tri_inout;

  Bidirectional UUT (.tri_inout(tri_inout), .data(data),
                     .data_in(data_in), .enable_in_out(enable_in_out));

  initial begin
    $display(" time enable data_in data | tri_inout");
    $monitor("%5d    %b      %b      %b   |    %b",
             $time, enable_in_out, data_in, data, tri_inout);
    // 題目情況：enable_in_out = 1, data_in = 1  -> tri_inout 跟著 data 走
    enable_in_out = 1; data_in = 1; data = 0;
    #20 data = 1;
    #20 data = 0;
    #20 data = 1;
    #20 data = 0;
    // 對照：enable_in_out = 0 -> 輸出關閉，tri_inout = z
    #20 enable_in_out = 0;
    #20 data = 1;
    #20 $finish;
  end
endmodule
// 【預期輸出】0~100ns：tri_inout 與 data 完全相同（0->1->0->1->0）；100ns 之後 tri_inout = z
// 【ModelSim 執行指令】 do run.do
