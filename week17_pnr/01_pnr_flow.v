// ============================================================
//  W17-1：完整跑一次佈局繞線流程
//  重點：★ 第 15 週我們用 build.bat 一鍵跑完，這週要【拆開來看】
//        每一步到底做了什麼、產生的檔案裡面是什麼
//
//  ⚠️ 課本沒有這部分。2.5 節有 Vivado 的畫面，但沒講原理。
// ============================================================
`timescale 1ns / 1ps

// ------------------------------------------------------------
//  一個中等大小的設計，拿來當佈局繞線的實驗對象
//  故意包含三種不同的資源，才看得出使用率報告的各欄位：
//    - 組合邏輯（LUT）
//    - 正反器（DFF）
//    - 進位鏈（CARRY）
// ------------------------------------------------------------
module pnr_demo (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] a, b,
    input  wire [2:0] op,

    output reg  [7:0] led,
    output reg        busy,
    output reg  [7:0] acc
);

    //  ---- 一台小 ALU（吃 LUT）----
    reg [7:0] alu_out;
    always @(*) begin
        case (op)
            3'd0: alu_out = a + b;
            3'd1: alu_out = a - b;
            3'd2: alu_out = a & b;
            3'd3: alu_out = a | b;
            3'd4: alu_out = a ^ b;
            3'd5: alu_out = a << 1;
            3'd6: alu_out = a >> 1;
            3'd7: alu_out = ~a;
            default: alu_out = 8'd0;
        endcase
    end

    //  ---- 累加器（吃 DFF + CARRY）----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) acc <= 8'd0;
        else        acc <= acc + alu_out;
    end

    //  ---- 一個計數器（吃 DFF + CARRY）----
    reg [15:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) cnt <= 16'd0;
        else        cnt <= cnt + 1'b1;
    end

    //  ---- 輸出（吃 DFF）----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led  <= 8'd0;
            busy <= 1'b0;
        end else begin
            led  <= acc ^ cnt[15:8];
            busy <= (cnt[7:0] != 8'd0);
        end
    end

endmodule

//  ---- 模擬 ----
//  iverilog -o sim.out 01_pnr_flow.v 01_pnr_flow_tb.v
//  vvp sim.out
//
//  ---- 逐步跑佈局繞線 ----
//  01_pnr_flow.bat
