`timescale 1ns/1ps

// =====================================================================
// FullAdd：1 位元全加器（講義第 3 頁）
//   這個檔案會被 FullAdd4.v 用 `include "FullAdd.v" 引入
//   ※ vlog 的檔案清單【不要】再列 FullAdd.v，否則 FullAdd 會被編譯兩次
// =====================================================================
module FullAdd (
    input  a,
    input  b,
    input  CarryIn,
    output Sum,
    output CarryOut
);
    assign {CarryOut, Sum} = a + b + CarryIn;
endmodule
