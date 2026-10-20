`timescale 1ns/1ps

// =====================================================================
// Decoder_3to8：3 對 8 解碼器，低態致能（G）、低態輸出（講義第 23~27 頁）
//   G = 1             → 不動作，D7 ~ D0 全部是 1
//   G = 0（Low Enable）→ {A2, A1, A0} 是幾，D 的第幾條就是 0（其他都是 1）
//   方塊圖輸出端的小圓圈 = 反相（Not）= 低態輸出
// =====================================================================
module Decoder_3to8 (
    input      A2, A1, A0,
    input      G,
    output reg D7, D6, D5, D4, D3, D2, D1, D0
);
    always @(*) begin           // 講義：always @(G or A2 or A1 or A0)（event list，敏感清單）
        if (G == 1'b0) begin
            case ({A2, A1, A0})     // 連結成 3 位元再比對
                3'b000:
                    begin           // 敘述多於一行，需使用 begin ... end
                        D7 = 1; D6 = 1; D5 = 1; D4 = 1;
                        D3 = 1; D2 = 1; D1 = 1; D0 = 0;
                    end
                3'b001:
                    begin
                        D7 = 1; D6 = 1; D5 = 1; D4 = 1;
                        D3 = 1; D2 = 1; D1 = 0; D0 = 1;
                    end
                3'b010:
                    begin
                        D7 = 1; D6 = 1; D5 = 1; D4 = 1;
                        D3 = 1; D2 = 0; D1 = 1; D0 = 1;
                    end
                3'b011:
                    begin
                        D7 = 1; D6 = 1; D5 = 1; D4 = 1;
                        D3 = 0; D2 = 1; D1 = 1; D0 = 1;
                    end
                3'b100:
                    begin
                        D7 = 1; D6 = 1; D5 = 1; D4 = 0;
                        D3 = 1; D2 = 1; D1 = 1; D0 = 1;
                    end
                3'b101:
                    begin
                        D7 = 1; D6 = 1; D5 = 0; D4 = 1;
                        D3 = 1; D2 = 1; D1 = 1; D0 = 1;
                    end
                3'b110:
                    begin
                        D7 = 1; D6 = 0; D5 = 1; D4 = 1;
                        D3 = 1; D2 = 1; D1 = 1; D0 = 1;
                    end
                3'b111:
                    begin
                        D7 = 0; D6 = 1; D5 = 1; D4 = 1;
                        D3 = 1; D2 = 1; D1 = 1; D0 = 1;
                    end
                default:            // 講義沒有 default；A 有 x 或 z 時 8 個 case 都比不到，補上讓輸出變 x
                    begin
                        {D7, D6, D5, D4, D3, D2, D1, D0} = 8'bxxxx_xxxx;
                    end
            endcase
        end
        else begin                  // G = 1'b1：不致能
            D7 = 1; D6 = 1; D5 = 1; D4 = 1;
            D3 = 1; D2 = 1; D1 = 1; D0 = 1;
        end
    end
endmodule
