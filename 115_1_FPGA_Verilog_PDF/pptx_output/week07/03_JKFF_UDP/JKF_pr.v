`timescale 1ns/1ps

// =====================================================================
// JKF_pr：使用者自定、具有重置功能的「準位觸發」JK 正反器（序向 UDP）（講義第 7~10 頁）
//   RST = 1           → Q = 0（重置）
//   CLK = 1 時（準位）：J K = 00 不變、01 → 0、10 → 1、11 → 反相（toggle）
//   CLK = 0           → 不變
//
// 這裡的 CLK 寫成 0、1（準位），不是 (01)（邊緣），所以是「準位觸發」
//   準位觸發的 UDP 在【任何一個輸入改變】時查一次表；CLK 維持 1 的期間 J、K 一變，Q 就跟著變
// =====================================================================
primitive JKF_pr (Q, J, K, CLK, RST);
    output Q;
    reg    Q;
    input  J, K, CLK, RST;

    initial Q = 1'b0;           // 講義第 7 頁：自定序向邏輯可以用 initial 設定輸出的起始值（講義的程式沒寫，補上）

    table
    //  J  K  CLK  RST  :  Q(n)  :  Q(n+1)
        ?  ?   ?    1   :   ?    :    0  ;   // Reset state
        0  0   1    0   :   ?    :    -  ;   // Output unchanged
        0  1   1    0   :   0    :    0  ;   // Output reset to 0 for Q(n)=0
        0  1   1    0   :   1    :    0  ;   // Output reset to 0 for Q(n)=1
        1  0   1    0   :   0    :    1  ;   // Output set to 1 for Q(n)=0（講義註解寫成 reset to 1）
        1  0   1    0   :   1    :    1  ;   // Output set to 1 for Q(n)=1
        1  1   1    0   :   0    :    1  ;   // Output changed（反相）
        1  1   1    0   :   1    :    0  ;   // Output changed（反相）
        ?  ?   0    0   :   ?    :    -  ;   // Output unchanged as CLK=0
    endtable
endprimitive
