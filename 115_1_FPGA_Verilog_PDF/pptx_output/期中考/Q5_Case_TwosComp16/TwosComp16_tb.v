// TwosComp16_tb.v : 16 位元 2 的補數測試平台（65536 種輸入全測）
`timescale 1ns/1ps
module TwosComp16_tb;
  reg  [15:0] In_Data;
  wire [15:0] Out_Data;
  integer k, err;

  TwosComp16 UUT (.In_Data(In_Data), .Out_Data(Out_Data));

  initial begin
    err = 0;
    $display(" In_Data (hex/dec) | Out_Data (hex/signed dec)");
    for (k = 0; k < 65536; k = k + 1) begin
      In_Data = k;
      #1;
      if (k == 0 || k == 1 || k == 2 || k == 104 || k == 1000 ||
          k == 32767 || k == 32768 || k == 65535)
        $display("  %h / %5d     |  %h / %0d", In_Data, In_Data, Out_Data, $signed(Out_Data));
      if (Out_Data !== (~In_Data + 16'd1)) err = err + 1;
      if ((In_Data + Out_Data) & 16'hffff) err = err + 1;   // X + (-X) = 0 (mod 2^16)
    end
    if (err == 0) $display("PASS: all 65536 inputs correct");
    else          $display("FAIL: %0d errors", err);
    $finish;
  end
endmodule
// 【預期輸出】0001->ffff(-1)、0068(104)->ff98(-104)、8000->8000；最後 PASS: all 65536 inputs correct
// 【ModelSim 執行指令】 do run.do
