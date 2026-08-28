module logic_gate (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [8:0] sum,
    output wire       big
);
    assign sum = a + b;
    assign big = (sum > 9'd200);
endmodule
