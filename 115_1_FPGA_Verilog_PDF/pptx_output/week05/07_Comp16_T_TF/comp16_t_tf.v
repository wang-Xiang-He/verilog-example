`timescale 1ns/1ps

// =====================================================================
// comp16_t_tf：16 位元比較器，任務呼叫任務與函數（範例練習 6-005，講義第 29~33 頁）
//   Yout = 100 → A > B      Yout = 010 → A = B      Yout = 001 → A < B
//   主模組呼叫任務 compare8 兩次（先比高 8 位元，相等才比低 8 位元）
//   compare8 再呼叫任務 compare4_T（比高 4 位元）與函數 compare4_F（比低 4 位元）
// =====================================================================
module comp16_t_tf (
    input      [15:0] A,        // 埠順序和講義相同：(A, B, Yout)
    input      [15:0] B,
    output reg [2:0]  Yout
);
    reg [7:0] A8bit;
    reg [7:0] B8bit;

    always @(*) begin           // 講義：always @(A or B)
        A8bit = A[15:8];
        B8bit = B[15:8];
        compare8(A8bit, B8bit, Yout);
        if (Yout == 3'b010) begin           // A[15:8] = B[15:8] → 還要比低 8 位元
            A8bit = A[7:0];
            B8bit = B[7:0];
            compare8(A8bit, B8bit, Yout);
        end
    end

    // 任務：8 位元比較，結果從 output S 傳回
    task compare8 (
        input  [7:0] I_A,
        input  [7:0] I_B,
        output [2:0] S
    );
        reg [3:0] A4bit;
        reg [3:0] B4bit;
        begin
            A4bit = I_A[7:4];
            B4bit = I_B[7:4];
            compare4_T(A4bit, B4bit, S);            // 任務呼叫任務
            if (S == 3'b010) begin                  // I_A[7:4] = I_B[7:4]
                A4bit = I_A[3:0];
                B4bit = I_B[3:0];
                S = compare4_F(A4bit, B4bit);       // 任務呼叫函數
            end
        end
    endtask

    // 任務版的 4 位元比較器
    //   講義寫 input [7:4] I_A, I_B；寬度一樣是 4 位元，這裡改成習慣的 [3:0]
    task compare4_T (
        input  [3:0] I_A,
        input  [3:0] I_B,
        output [2:0] S
    );
        begin
            if (I_A > I_B)
                S = 3'b100;
            else if (I_A == I_B)
                S = 3'b010;
            else
                S = 3'b001;
        end
    endtask

    // 函數版的 4 位元比較器：功能和 compare4_T 完全相同，差別只在「怎麼把結果交回去」
    function [2:0] compare4_F (
        input [3:0] I_A,
        input [3:0] I_B
    );
        begin
            if (I_A > I_B)
                compare4_F = 3'b100;
            else if (I_A == I_B)
                compare4_F = 3'b010;
            else
                compare4_F = 3'b001;
        end
    endfunction
endmodule
