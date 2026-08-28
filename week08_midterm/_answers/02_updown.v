`timescale 1ns / 1ps
module updown #(
    parameter W = 4
)(
    input  wire         clk,
    input  wire         rst,
    input  wire         load,
    input  wire         en,
    input  wire         up,
    input  wire [W-1:0] din,
    output reg  [W-1:0] count,
    output wire         at_max,
    output wire         at_min
);
    always @(posedge clk) begin
        if (rst)       count <= {W{1'b0}};
        else if (load) count <= din;
        else if (en)   count <= up ? count + 1'b1 : count - 1'b1;
    end

    assign at_max = (count == {W{1'b1}});
    assign at_min = (count == {W{1'b0}});
endmodule
