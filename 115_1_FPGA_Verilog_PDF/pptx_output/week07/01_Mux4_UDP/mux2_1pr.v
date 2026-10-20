`timescale 1ns/1ps

// =====================================================================
// mux2_1pr：使用者自定的 2 對 1 多工器（User-Defined Primitive, UDP）（講義第 1、3 頁）
//   S = 0 → Y = I0；S = 1 → Y = I1
//
// UDP 的規則：
//   1. 用 primitive ... endprimitive 包起來，寫在 module 的【外面】
//   2. 只能有 1 個輸出，而且輸出一定是第 1 個埠；輸入可以有很多個，但每個都只能是 1 位元
//   3. 真值表 table ... endtable 的每一行：<輸入1> <輸入2> ... <輸入n> : <輸出> ;
//      輸入的排列順序必須和【埠宣告的順序】一樣（這裡是 I1 I0 S），否則輸出會錯
//   4. 表中可以用 0、1、x，以及 ?（= 0、1、x 任何一個都可以）
//   5. 沒有列在表裡的輸入組合，輸出一律是 x
// =====================================================================
primitive mux2_1pr (Y, I1, I0, S);
    output Y;
    input  I1, I0;
    input  S;
    // ※ UDP 的埠宣告講義用 Verilog-1995 寫法；Verilog-2001 也可以寫成
    //     primitive mux2_1pr (output Y, input I1, input I0, input S);

    table
    //  I1  I0   S  :  Y        // Look-up table
         ?   0   0  :  0 ;      // S = 0：輸出 I0（I1 是什麼都沒關係）
         ?   1   0  :  1 ;
         0   ?   1  :  0 ;      // S = 1：輸出 I1（I0 是什麼都沒關係）
         1   ?   1  :  1 ;
         ?   ?   x  :  x ;      // S 不確定 → 輸出不確定
    endtable
endprimitive
