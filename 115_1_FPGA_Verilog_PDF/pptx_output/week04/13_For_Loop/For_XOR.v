`timescale 1ns/1ps

// =====================================================================
// For_XOR：for 迴圈範例（講義第 41、42 頁）
//   Out[i] = a[i] ^ b[i]           （逐位元 XOR）
//   c      = 每一位的 (a[i] | b[i]) 全部 AND 起來
//   for 迴圈在「編譯時」就展開成 4 份電路，不是執行時一圈一圈跑
// =====================================================================
module For_XOR (
    input      [3:0] a,
    input      [3:0] b,
    output reg [3:0] Out,
    output reg       c
);
    always @(*) begin : for_loop_test    // 區塊有名字，才能在裡面宣告 integer i
        integer i;
        c = 1'b1;                        // 講義沒給初值，見說明
        for (i = 0; i <= 3; i = i + 1) begin
            Out[i] = a[i] ^ b[i];
            c = (a[i] | b[i]) & c;
        end
    end
    // 展開後等同於：
    //   Out[0] = a[0] ^ b[0];  Out[1] = a[1] ^ b[1];
    //   Out[2] = a[2] ^ b[2];  Out[3] = a[3] ^ b[3];
    //   c = (a[0] | b[0]) & (a[1] | b[1]) & (a[2] | b[2]) & (a[3] | b[3]);
endmodule
