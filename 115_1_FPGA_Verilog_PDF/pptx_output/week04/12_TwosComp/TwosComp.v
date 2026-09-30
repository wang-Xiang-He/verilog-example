`timescale 1ns/1ps

// =====================================================================
// TwosComp：8 位元 2 的補數，用 casex 實作（講義第 37~39 頁）
//   規則：從最低位元往上找到第一個 1，這個 1 和它右邊的位元保持不變，
//         左邊的位元全部反相 → 用 XOR 一個遮罩（mask）完成
//   例：In_Data = 1101_0011，第一個 1 在第 0 位
//       ^ 1111_1110 (fe) = 0010_1101 = -(1101_0011)
// =====================================================================
module TwosComp (
    input      [7:0] In_Data,
    output reg [7:0] Out_Data
);
    always @(*) begin           // 講義：always @(In_Data)
        casex (In_Data)         // synopsys parallel_case
            8'b???????1 : Out_Data = In_Data ^ 8'hfe;  // fe = 1111_1110
            8'b??????10 : Out_Data = In_Data ^ 8'hfc;  // fc = 1111_1100
            8'b?????100 : Out_Data = In_Data ^ 8'hf8;  // f8 = 1111_1000
            8'b????1000 : Out_Data = In_Data ^ 8'hf0;  // f0 = 1111_0000
            8'b???10000 : Out_Data = In_Data ^ 8'he0;  // e0 = 1110_0000
            8'b??100000 : Out_Data = In_Data ^ 8'hc0;  // c0 = 1100_0000
            8'b?1000000 : Out_Data = In_Data ^ 8'h80;  // 80 = 1000_0000
            8'b10000000 : Out_Data = In_Data ^ 8'h00;  // 00 = 0000_0000
            default     : Out_Data = In_Data;          // In_Data = 0，0 的 2 補數還是 0
        endcase
    end
endmodule
