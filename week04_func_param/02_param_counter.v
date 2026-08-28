// ============================================================
//  W4-2：parameter —— 讓同一份程式碼變出不同大小的電路
//  重點：改一個數字，整個電路跟著變大變小
// ============================================================
`timescale 1ns / 1ps

module param_counter #(
    parameter WIDTH   = 4,          // 幾位元
    parameter MAX     = 9           // 數到多少就歸零（BCD 就設 9）
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             en,
    output reg  [WIDTH-1:0] count,
    output wire             tick     // 數到頂的那一拍拉高（給下一級用）
);

    //  localparam：模組內部用的常數，外面不能改
    localparam [WIDTH-1:0] MAXV = MAX[WIDTH-1:0];

    assign tick = en && (count == MAXV);

    always @(posedge clk) begin
        if (rst)            count <= 0;
        else if (!en)       count <= count;
        else if (count == MAXV) count <= 0;
        else                count <= count + 1'b1;
    end

endmodule
