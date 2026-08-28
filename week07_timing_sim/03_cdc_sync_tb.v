`timescale 1ns / 100ps

module cdc_sync_tb;
    reg clk_dst = 0, rst;
    reg async_in;
    wire unsafe_out, safe_out, sync_ff1;

    cdc_sync uut (.clk_dst(clk_dst), .rst(rst), .async_in(async_in),
                  .unsafe_out(unsafe_out), .safe_out(safe_out), .sync_ff1(sync_ff1));

    always #5 clk_dst = ~clk_dst;    // 100 MHz

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, cdc_sync_tb);

        $display("");
        $display("   目的端時脈 100MHz（週期 10ns）");
        $display("   async_in 是「不知道什麼時候會變」的外來訊號");
        $display("");

        rst = 1; async_in = 0;
        #20 rst = 0;

        // 在各種奇怪的時間點改變 async_in，包含時脈邊緣附近
        #13 async_in = 1;       // 邊緣附近
        #17 async_in = 0;
        #10.2 async_in = 1;     // 幾乎剛好在邊緣上
        #23 async_in = 0;
        #7  async_in = 1;
        #40 async_in = 0;
        #30;

        $display("   看波形三條線的關係：");
        $display("     async_in    ── 隨便什麼時候都可能變");
        $display("     sync_ff1    ── 慢一拍（第一級）");
        $display("     safe_out    ── 再慢一拍（第二級，乾淨）");
        $display("");
        $display("  ★★ 為什麼要兩顆正反器？");
        $display("     訊號在時脈邊緣「正好」變化時，正反器會進入「亞穩態」");
        $display("     —— 輸出卡在 0 和 1 中間，要花不定的時間才穩定。");
        $display("");
        $display("     第一顆 FF 可能亞穩態，但我們給它一整個時脈週期恢復；");
        $display("     第二顆 FF 取到的就是穩定的值。");
        $display("");
        $display("     代價：延遲兩拍。好處：不會當機。");
        $display("");
        $display("  ★ 規則：任何跨時脈域的訊號，一律先過雙 FF 同步器。");
        $display("    （模擬看不出亞穩態 —— 那是類比現象。這是必須靠");
        $display("      「知道規則」而不是「靠模擬」來避免的錯誤。）");
        $display("");
        $finish;
    end
endmodule
