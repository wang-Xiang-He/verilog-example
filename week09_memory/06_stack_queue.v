// ============================================================
//  W9-6：用 RAM 做堆疊與佇列          ← 課本 12.3.1 / 12.3.2
//  重點：★ 堆疊和佇列【不是新的硬體】，就是一塊 RAM + 幾個指標暫存器
//        差別只在「指標怎麼動」
//
//        堆疊 Stack：一根指標，push 往上、pop 往下      → 後進先出 LIFO
//        佇列 Queue：兩根指標，寫的往前、讀的也往前     → 先進先出 FIFO
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  一、堆疊（課本 12.3.1）
//     只有一根 sp（stack pointer）
// ------------------------------------------------------------
module stack #(
    parameter DW    = 8,
    parameter DEPTH = 8,
    parameter AW    = 3            // log2(DEPTH)
) (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          push,
    input  wire          pop,
    input  wire [DW-1:0] din,

    output wire [DW-1:0] top,      // 堆疊最上面那個（不用 pop 就看得到）
    output wire          empty,
    output wire          full,
    output wire [AW:0]   count
);
    reg [DW-1:0] mem [0:DEPTH-1];
    reg [AW:0]   sp;               // 多一位，才分得出「空」和「滿」

    assign empty = (sp == 0);
    assign full  = (sp == DEPTH);
    assign count = sp;

    //  ★ top 是「非同步讀」：指到 sp-1 那格，直接接出來
    assign top = empty ? {DW{1'b0}} : mem[sp-1];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sp <= 0;
        end else begin
            //  ★ 同時 push 和 pop 時的優先權要自己定義清楚，
            //    這種角落情況不寫明白就是 bug 的溫床
            if (push && !pop && !full) begin
                mem[sp] <= din;
                sp      <= sp + 1;
            end else if (pop && !push && !empty) begin
                sp <= sp - 1;
                //  ★ pop 不用清除 mem 的內容 —— 反正下次 push 會覆蓋掉。
                //    真的去清是白花電路。
            end else if (push && pop && !empty) begin
                //  同時來：等於把最上面那個換掉，sp 不動
                mem[sp-1] <= din;
            end
        end
    end
endmodule


// ------------------------------------------------------------
//  二、佇列（課本 12.3.2）
//     兩根指標：wp 寫、rp 讀。這其實就是第 4 個範例 FIFO 的骨架。
// ------------------------------------------------------------
module queue #(
    parameter DW    = 8,
    parameter DEPTH = 8,
    parameter AW    = 3
) (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          wr,
    input  wire          rd,
    input  wire [DW-1:0] din,

    output wire [DW-1:0] front,    // 佇列最前面那個
    output wire          empty,
    output wire          full,
    output wire [AW:0]   count
);
    reg [DW-1:0] mem [0:DEPTH-1];
    reg [AW:0]   wp, rp;           // 兩根都多一位

    //  ★ 空滿判斷的經典寫法：
    //    位址部分相同 + 最高位相同 → 空
    //    位址部分相同 + 最高位不同 → 滿（wp 比 rp 多繞了一圈）
    assign empty = (wp == rp);
    assign full  = (wp[AW] != rp[AW]) && (wp[AW-1:0] == rp[AW-1:0]);
    assign count = wp - rp;

    assign front = empty ? {DW{1'b0}} : mem[rp[AW-1:0]];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wp <= 0;
            rp <= 0;
        end else begin
            if (wr && !full) begin
                mem[wp[AW-1:0]] <= din;
                wp <= wp + 1;
            end
            //  ★ 讀和寫是【互相獨立】的，可以同一拍一起做 ——
            //    這是佇列和堆疊最大的結構差異
            if (rd && !empty) begin
                rp <= rp + 1;
            end
        end
    end
endmodule


// ------------------------------------------------------------
//  包起來方便測
// ------------------------------------------------------------
module stack_queue (
    input  wire       clk, rst_n,
    input  wire       push, pop, wr, rd,
    input  wire [7:0] din,

    output wire [7:0] s_top,  q_front,
    output wire       s_empty, s_full, q_empty, q_full,
    output wire [3:0] s_count, q_count
);
    stack #(.DW(8), .DEPTH(8), .AW(3)) u_stack (
        .clk(clk), .rst_n(rst_n), .push(push), .pop(pop), .din(din),
        .top(s_top), .empty(s_empty), .full(s_full), .count(s_count)
    );

    queue #(.DW(8), .DEPTH(8), .AW(3)) u_queue (
        .clk(clk), .rst_n(rst_n), .wr(wr), .rd(rd), .din(din),
        .front(q_front), .empty(q_empty), .full(q_full), .count(q_count)
    );
endmodule

//  iverilog -o sim.out 06_stack_queue.v 06_stack_queue_tb.v
//  vvp sim.out
//  gtkwave 06_stack_queue.gtkw
