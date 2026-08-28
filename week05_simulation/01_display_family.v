// ============================================================
//  W5-1：$display / $write / $monitor / $strobe 四兄弟
//  重點：四個都是印字，但「什麼時候印」完全不同
// ============================================================
`timescale 1ns / 1ps

module dut (
    input  wire clk,
    input  wire [3:0] d,
    output reg  [3:0] q
);
    always @(posedge clk) q <= d;
endmodule
