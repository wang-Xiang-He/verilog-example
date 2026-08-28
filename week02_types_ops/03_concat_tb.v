`timescale 1ns / 1ps

module concat_tb;

    reg  [3:0] a, b;
    wire [7:0] joined, swapped, repeated, mixed, sign_ext;
    wire [3:0] reversed;

    concat uut (
        .a(a), .b(b), .joined(joined), .swapped(swapped),
        .repeated(repeated), .reversed(reversed),
        .mixed(mixed), .sign_ext(sign_ext)
    );

    task show;
        begin
            $display("");
            $display("  a = %b   b = %b", a, b);
            $display("    {a,b}          = %b   把兩束接起來", joined);
            $display("    {b,a}          = %b   對調", swapped);
            $display("    {2{a}}         = %b   複製兩次", repeated);
            $display("    a 前後顛倒     = %b", reversed);
            $display("    {a[3:2],2'b01,b} = %b   夾常數", mixed);
            $display("    {{4{a[3]}},a}  = %b   符號延伸 (a[3]=%b)", sign_ext, a[3]);
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, concat_tb);

        a = 4'b1100; b = 4'b0011; #20 show;
        a = 4'b0101; b = 4'b1111; #20 show;
        a = 4'b1000; b = 4'b0001; #20 show;

        $display("");
        $display("  ★ 符號延伸的用意：");
        $display("    4'b1000 當有號數是 -8。要放進 8 位元又保持 -8，");
        $display("    不能補 0（會變成 8），要補最高位 → 8'b11111000 = -8");
        $display("");

        #20 $finish;
    end

endmodule
