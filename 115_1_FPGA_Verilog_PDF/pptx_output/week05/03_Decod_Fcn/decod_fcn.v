`timescale 1ns/1ps

// =====================================================================
// decod_fcn：用 2 對 4 解碼器函數做出 3 對 8 解碼器（範例練習 6-002，講義第 9~12 頁）
//   Din[1:0] 同時送給兩個 2 對 4 解碼器，Din[2] 決定哪一個致能（ce）
//     Din[2] = 0 → 下半部 Y[3:0] 動作
//     Din[2] = 1 → 上半部 Y[7:4] 動作
// =====================================================================
module decod_fcn (
    input  [2:0] Din,           // 埠順序和講義相同：(Din, Y)
    output [7:0] Y
);
    reg [7:0] Ytmp;

    always @(*) begin           // 講義：always @(Din)
        Ytmp[7:4] = decod4(Din[1:0],  Din[2]);
        Ytmp[3:0] = decod4(Din[1:0], ~Din[2]);
    end

    assign Y = Ytmp;

    // 2 對 4 解碼器：ce = 1 時依 D 輸出 0001 / 0010 / 0100 / 1000，ce = 0 時輸出 0000
    function [3:0] decod4 (
        input [1:0] D,
        input       ce
    );
        if (ce == 1'b1) begin
            case (D)
                2'b00   : decod4 = 4'b0001;
                2'b01   : decod4 = 4'b0010;
                2'b10   : decod4 = 4'b0100;
                2'b11   : decod4 = 4'b1000;
                default : decod4 = 4'b0000;
            endcase
        end
        else
            decod4 = 4'b0000;
    endfunction
endmodule
