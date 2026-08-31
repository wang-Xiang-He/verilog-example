`timescale 1ns / 1ps

module alu_hier_tb;
    reg  [7:0] a, b;
    reg  [3:0] op;
    wire [7:0] y;
    wire       carry, zero;

    integer i, err;
    reg [7:0] exp;
    reg [8:0] t;

    alu_hier #(.W(8)) uut (.a(a), .b(b), .op(op), .y(y), .carry(carry), .zero(zero));

    //  參考模型：不管硬體怎麼分層，行為應該一樣
    task ref_model;
        input [3:0]  o;
        input [7:0]  x, z;
        output [7:0] r;
        begin
            case (o[3:2])
                2'd0: begin   // 算術
                    if (o[0]) r = x - z;
                    else      r = x + z;
                end
                2'd1: begin   // 邏輯
                    case (o[1:0])
                        2'd0: r = x & z;
                        2'd1: r = x | z;
                        2'd2: r = x ^ z;
                        2'd3: r = ~x;
                    endcase
                end
                2'd2: begin   // 位移
                    case (o[1:0])
                        2'd0: r = x << 1;
                        2'd1: r = x >> 1;
                        2'd2: r = $signed(x) >>> 1;
                        2'd3: r = x;
                    endcase
                end
                default: r = 8'd0;
            endcase
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, alu_hier_tb);
        err = 0;

        $display("");
        $display("  ============================================================");
        $display("   分層版 ALU：一個頂層 + 四顆子模組");
        $display("  ============================================================");

        $display("");
        $display("  ===== 一、逐一測試每個功能（a=8'hF0, b=8'h0C）=====");
        $display("");
        $display("   op   單元    功能    |    y     | carry zero");
        $display("   ---------------------+----------+-----------");
        a = 8'hF0; b = 8'h0C;

        op = 4'b0000; #10;
        $display("   %b  算術    加法    | %b |   %0d    %0d", op, y, carry, zero);
        op = 4'b0001; #10;
        $display("   %b  算術    減法    | %b |   %0d    %0d", op, y, carry, zero);
        op = 4'b0100; #10;
        $display("   %b  邏輯    AND     | %b |   %0d    %0d", op, y, carry, zero);
        op = 4'b0101; #10;
        $display("   %b  邏輯    OR      | %b |   %0d    %0d", op, y, carry, zero);
        op = 4'b0110; #10;
        $display("   %b  邏輯    XOR     | %b |   %0d    %0d", op, y, carry, zero);
        op = 4'b0111; #10;
        $display("   %b  邏輯    NOT a   | %b |   %0d    %0d", op, y, carry, zero);
        op = 4'b1000; #10;
        $display("   %b  位移    左移    | %b |   %0d    %0d", op, y, carry, zero);
        op = 4'b1001; #10;
        $display("   %b  位移    邏輯右移| %b |   %0d    %0d", op, y, carry, zero);
        op = 4'b1010; #10;
        $display("   %b  位移    算術右移| %b |   %0d    %0d", op, y, carry, zero);

        // ============================================================
        $display("");
        $display("  ===== 二、★ 從外面直接看子模組內部的線 =====");
        $display("");
        $display("   Verilog 可以用【階層式路徑】直接抓到深層的訊號：");
        $display("");
        op = 4'b0000; a = 8'd100; b = 8'd50; #10;
        $display("     uut.w_arith          = %d   ← 頂層裡的連接線", uut.w_arith);
        $display("     uut.w_logic          = %d", uut.w_logic);
        $display("     uut.w_shift          = %d", uut.w_shift);
        $display("     uut.u_arith.b_in     = %d   ★ 鑽進子模組裡面的線", uut.u_arith.b_in);
        $display("     uut.u_arith.sum      = %d", uut.u_arith.sum);
        $display("");
        $display("   ★ 注意 w_arith / w_logic / w_shift 【三個同時都有值】——");
        $display("     三顆單元一直都在算，多工器只是挑一個送出去。");
        $display("     這就是硬體和軟體最根本的差別。");
        $display("");
        $display("   ⚠️ 階層式路徑只能用在【測試平台】，設計檔裡不能這樣寫（不能合成）。");

        // ============================================================
        $display("");
        $display("  ===== 三、隨機 3000 組對照參考模型 =====");
        for (i = 0; i < 3000; i = i + 1) begin
            a  = $random;
            b  = $random;
            op = $random;
            #1;
            if (op[3:2] != 2'd3) begin
                ref_model(op, a, b, exp);
                if (y !== exp) begin
                    err = err + 1;
                    if (err <= 5)
                        $display("   [X] op=%b a=%h b=%h → y=%h 應該 %h", op, a, b, y, exp);
                end
            end
        end

        $display("");
        $display("  ------------------------------------------------------------");
        if (err == 0) $display("   ★ 分層版和參考模型完全一致，0 個錯");
        else          $display("   [X] 有 %0d 組不符", err);

        $display("");
        $display("   ★★ 對照第 3 週的 12_alu（平的那顆）：");
        $display("");
        $display("                     平的一顆          分成四顆");
        $display("     -------------------------------------------------------");
        $display("     讀程式碼        一路往下讀        要跳來跳去");
        $display("     改一個功能      要小心動到別的    只改那一顆，其他不用看");
        $display("     重複使用        整顆搬走          可以只拿 alu_arith");
        $display("     波形除錯        只看得到輸入輸出  ★ 每個中間結果都看得到");
        $display("     綜合出來的面積  幾乎一樣          幾乎一樣");
        $display("");
        $display("     ★ 分層【不會讓電路變快或變小】，它換到的是");
        $display("       「人看得懂」和「改得動」。設計大電路時這比什麼都重要。");
        $display("");
        #20 $finish;
    end
endmodule
