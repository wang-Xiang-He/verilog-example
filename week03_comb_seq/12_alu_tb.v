`timescale 1ns / 1ps

module alu_tb;
    reg  [7:0] a, b;
    reg  [3:0] op;
    wire [7:0] y;
    wire       carry, zero, neg;

    integer i, err;
    reg [7:0] exp;
    reg       exp_c;

    //  給每個 op 一個看得懂的名字，印表格用
    reg [39:0] name;

    alu uut (.a(a), .b(b), .op(op), .y(y), .carry(carry), .zero(zero), .neg(neg));

    //  依 op 算出「應該是多少」，用來自動判分
    task expect_of;
        input [3:0]  o;
        input [7:0]  x, z;
        output [7:0] ey;
        output       ec;
        reg [8:0]    t;
        begin
            ec = 1'b0; t = 9'd0;
            case (o)
                4'd0:  begin t = {1'b0,x} + {1'b0,z}; ey = t[7:0]; ec = t[8]; end
                4'd1:  begin t = {1'b0,x} - {1'b0,z}; ey = t[7:0]; ec = t[8]; end
                4'd2:  ey = x & z;
                4'd3:  ey = x | z;
                4'd4:  ey = x ^ z;
                4'd5:  ey = ~x;
                4'd6:  begin ey = x << 1;           ec = x[7]; end
                4'd7:  begin ey = x >> 1;           ec = x[0]; end
                4'd8:  begin ey = $signed(x) >>> 1; ec = x[0]; end
                4'd9:  ey = (x > z) ? 8'd1 : 8'd0;
                4'd10: begin t = {1'b0,x} + 9'd1;   ey = t[7:0]; ec = t[8]; end
                4'd11: begin t = {1'b0,x} - 9'd1;   ey = t[7:0]; ec = t[8]; end
                4'd12: ey = x;
                4'd13: ey = z;
                default: ey = 8'd0;
            endcase
        end
    endtask

    always @(*) begin
        case (op)
            4'd0:  name = "ADD  ";
            4'd1:  name = "SUB  ";
            4'd2:  name = "AND  ";
            4'd3:  name = "OR   ";
            4'd4:  name = "XOR  ";
            4'd5:  name = "NOT a";
            4'd6:  name = "SHL  ";
            4'd7:  name = "SHR  ";
            4'd8:  name = "SAR  ";
            4'd9:  name = "CMP  ";
            4'd10: name = "INC a";
            4'd11: name = "DEC a";
            4'd12: name = "PASSA";
            4'd13: name = "PASSB";
            default: name = "---  ";
        endcase
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, alu_tb);
        err = 0;

        $display("");
        $display("  ===== 一、a=8'hF0(240/-16), b=8'h0C(12) 跑過所有指令 =====");
        $display("");
        $display("   op  名稱  |   y (bin)    y(u)  y(s) | C  Z  N");
        $display("   ----------+--------------------------+---------");
        a = 8'hF0; b = 8'h0C;
        for (i = 0; i < 14; i = i + 1) begin
            op = i[3:0]; #10;
            expect_of(op, a, b, exp, exp_c);
            if (y === exp && carry === exp_c)
                $display("   %2d  %0s |  %b  %4d  %4d | %0d  %0d  %0d",
                         op, name, y, y, $signed(y), carry, zero, neg);
            else
                $display("   %2d  %0s |  %b  %4d  %4d | %0d  %0d  %0d   <== [X] 不符",
                         op, name, y, y, $signed(y), carry, zero, neg);
            if (y !== exp || carry !== exp_c) err = err + 1;
        end

        $display("");
        $display("  ===== 二、旗標的意義 =====");
        $display("");
        op = 4'd1;                       // SUB
        a = 8'd50; b = 8'd50; #10;
        $display("   50 - 50 = %0d   zero=%0d  ← ★ zero 旗標就是「結果剛好是 0」", y, zero);
        a = 8'd10; b = 8'd20; #10;
        $display("   10 - 20 = %0d  carry=%0d  ← ★ 減法的 carry 其實是【借位】", y, carry);
        $display("                  neg=%0d  ← 當成有號數看是 %0d", neg, $signed(y));
        op = 4'd0;                       // ADD
        a = 8'd200; b = 8'd100; #10;
        $display("   200+100 = %0d  carry=%0d  ← ★ 300 放不進 8 位元，進位告訴你溢位了",
                 y, carry);

        $display("");
        $display("  ===== 三、SHR vs SAR（邏輯右移 vs 算術右移）=====");
        $display("");
        a = 8'hF0;
        op = 4'd7; #10;
        $display("   SHR: %b >> 1  = %b  無號 240 -> %0d", a, y, y);
        op = 4'd8; #10;
        $display("   SAR: %b >>>1  = %b  有號 -16 -> %0d", a, y, $signed(y));
        $display("   ★ 同一組位元，補 0 還是補符號位，差在這裡");

        $display("");
        $display("  ===== 四、隨機 2000 組全自動比對 =====");
        for (i = 0; i < 2000; i = i + 1) begin
            a  = $random;
            b  = $random;
            op = $random;
            #1;
            expect_of(op, a, b, exp, exp_c);
            if (op < 4'd14 && (y !== exp || carry !== exp_c)) begin
                err = err + 1;
                if (err < 5)
                    $display("   [X] op=%0d a=%h b=%h  得到 y=%h c=%0d  應該 y=%h c=%0d",
                             op, a, b, y, carry, exp, exp_c);
            end
        end

        $display("");
        $display("  ------------------------------------------------------------");
        if (err == 0)
            $display("   ★ 全部通過，0 個錯");
        else
            $display("   [X] 共 %0d 個錯", err);
        $display("");
        $display("   延伸：第 10 週的 01_alu_hier 會把這顆【拆成三個子模組】");
        $display("         （加法器 / 邏輯單元 / 多工器），比較兩種寫法的差別。");
        $display("");
        #20 $finish;
    end
endmodule
