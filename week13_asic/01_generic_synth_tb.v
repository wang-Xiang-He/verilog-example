`timescale 1ns / 1ps

module generic_synth_tb;
    reg  a, b, cin;
    wire sum, cout;

    reg  [3:0] a4, b4;
    reg        cin4;
    wire [3:0] sum4;
    wire       cout4;

    reg        clk, rst_n;
    wire [3:0] q;

    reg  [1:0] op;
    wire [3:0] y;

    integer i, err;

    fa       u_fa  (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));
    adder4   u_ad  (.a(a4), .b(b4), .cin(cin4), .sum(sum4), .cout(cout4));
    counter4 u_cnt (.clk(clk), .rst_n(rst_n), .q(q));
    alu4     u_alu (.a(a4), .b(b4), .op(op), .y(y));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, generic_synth_tb);
        clk = 0; rst_n = 0; err = 0;
        a = 0; b = 0; cin = 0; a4 = 0; b4 = 0; cin4 = 0; op = 0;
        #12 rst_n = 1;

        $display("");
        $display("  ============================================================");
        $display("   ASIC 流程：先確認功能，再走綜合 → 元件映射");
        $display("  ============================================================");

        $display("");
        $display("  ===== 功能驗證 =====");
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i[2:0]; #1;
            if ({cout, sum} !== (a + b + cin)) err = err + 1;
        end
        for (i = 0; i < 512; i = i + 1) begin
            {cin4, a4, b4} = i[8:0]; #1;
            if ({cout4, sum4} !== (a4 + b4 + cin4)) err = err + 1;
        end
        for (i = 0; i < 1024; i = i + 1) begin
            {op, a4, b4} = i[9:0]; #1;
            case (op)
                2'd0: if (y !== ((a4 + b4) & 4'hF)) err = err + 1;
                2'd1: if (y !== ((a4 - b4) & 4'hF)) err = err + 1;
                2'd2: if (y !== (a4 & b4))          err = err + 1;
                2'd3: if (y !== (a4 ^ b4))          err = err + 1;
            endcase
        end
        if (err == 0) $display("   ★ fa / adder4 / alu4 全部正確");
        else          $display("   [X] 有 %0d 處錯誤", err);

        $display("");
        $write("   counter4 數 6 拍： ");
        for (i = 0; i < 6; i = i + 1) begin
            @(negedge clk);
            $write("%0d ", q);
        end
        $display("");

        // ============================================================
        $display("");
        $display("  ============================================================");
        $display("   ★★ ASIC vs FPGA：整條流程的對照");
        $display("");
        $display("     步驟          FPGA                ASIC");
        $display("     ---------------------------------------------------------");
        $display("     1 綜合        synth_ice40         synth（通用閘）");
        $display("     2 元件映射    （沒這步，就是LUT） dfflibmap + abc -liberty");
        $display("     3 佈局繞線    nextpnr-ice40       商用 P&R 工具");
        $display("     4 時序分析    icetime             PrimeTime / OpenSTA");
        $display("     5 驗證        上板子測            DRC + LVS + 形式驗證");
        $display("     6 產出        bitstream 檔        GDSII 光罩檔");
        $display("     7 製造        燒進去就好          送晶圓廠，3~6 個月");
        $display("     8 改錯        重燒，5 秒          ★ 重跑光罩，幾千萬台幣");
        $display("");
        $display("   ★ 第 8 行就是為什麼 ASIC 要做形式驗證（04_formal）——");
        $display("     FPGA 錯了重燒就好；ASIC 錯了，那批晶片全部報廢。");
        $display("     所以「測試涵蓋率 99%%」在 ASIC 是不夠的，");
        $display("     關鍵性質要用【數學證明】它永遠不會錯。");
        $display("");
        $display("   下一步：");
        $display("     01_generic_synth.bat   綜合成通用閘");
        $display("     02_liberty_map.bat     映射到標準元件庫");
        $display("  ============================================================");
        $display("");
        #20 $finish;
    end
endmodule
