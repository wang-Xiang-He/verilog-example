// Bidirectional.v : 雙向（inout）腳位驅動範例（期中考 第 4 題）
module Bidirectional (tri_inout, data, data_in, enable_in_out);
  inout tri_inout;            // pin 24
  input data;                 // pin 21
  input data_in;              // pin 23（多工器選擇線）
  input enable_in_out;        // pin 26（三態緩衝器致能）

  assign tri_inout = enable_in_out ?
                     ((data_in) ? data : tri_inout) : 1'bz;
endmodule
