# 05_Param_Multi 範例說明：一次改寫多個 parameter

## 1. 這個範例在做什麼？

講義第 11~14 頁的「New "#" Description」：`Adder` 改成有**兩個參數** `size1`、`size2`，
實例化時用 `#(our_size1, our_size2)` **一次傳兩個值**。

```verilog
Adder #(our_size1, our_size2) My_Adder16 (A, B, Carry_In, Sum, Carry_Out);
//      ↓          ↓
//      size1      size2          依順序：第 1 個給第 1 個、第 2 個給第 2 個
```

講義第 13 頁的重點：

> **主程式與副程式的呼叫：一對一、多對多，或少對多均可，但多對少不可以。**

意思是：`#( )` 裡**給的值的個數**，可以等於或少於模組的參數個數，但**不能多於**。

| 情況 | 例子（Adder 有 2 個參數） | 可以嗎 |
|------|-------------------------|--------|
| 一對一 | 只有 1 個參數的模組給 1 個值 | ✓ |
| 多對多 | `Adder #(8, 16)` | ✓ 兩個都改 |
| 少對多 | `Adder #(4)` | ✓ 只改 size1，size2 保留預設 |
| 多對少 | `Adder #(4, 8, 16)` | ✗ 載入模擬時出錯 |

---

## 2. 檔案說明

| 檔案 | 用途 |
|------|------|
| `Scalable.v` | 新版 `Adder`，有 `size1 = 1`、`size2 = 2` 兩個參數 |
| `Adder16.v` | `` `include "Scalable.v" ``，用 `#(our_size1, our_size2)` 傳兩個值 |
| `Adder16_tb.v` | 測試平台（講義第 13 頁的 Adder16_test.v，模組名稱 t） |
| `run.do` | `vlog Adder16.v Adder16_tb.v` |

### Scalable.v（講義第 11 頁）
```verilog
module Adder #(
    parameter size1 = 1,            // A、B、Sum 的寬度
    parameter size2 = 2             // 這個電路沒用到，只是示範「傳好幾個參數」
) (
    input  [size1-1:0] A,
    input  [size1-1:0] B,
    input              Carry_In,
    output [size1-1:0] Sum,
    output             Carry_Out
);
    assign {Carry_Out, Sum} = A + B + Carry_In;
endmodule
```

> 講義第 11 頁還有一行 `wire [size1-1:0] sum;`（小寫 s）。Verilog **大小寫有別**，
> `sum` 和 `Sum` 是兩條不同的線，而且 `sum` 沒有被用到。ANSI 寫法不需要另外宣告 wire，這行就拿掉了。

> 講義第 11、12 頁有些中文註解是亂碼（編碼轉換時壞掉了），不影響程式。

### Adder16.v（講義第 12 頁）
```verilog
module Adder16 #(
    parameter our_size1 = 8,
    parameter our_size2 = 16
) ( ... [our_size1-1:0] ... );
    Adder #(our_size1, our_size2) My_Adder16 (A, B, Carry_In, Sum, Carry_Out);
endmodule
```
模組名稱叫 `Adder16`，但 `our_size1 = 8`，所以**實際上是 8 位元**加法器。講義第 14 頁的波形也是 8 位元，兩者一致。

依名稱的寫法（建議，參數多的時候不會給錯順序）：
```verilog
Adder #(.size1(our_size1), .size2(our_size2)) My_Adder16 (...);
```

### Adder16_tb.v（講義第 13 頁）
```verilog
parameter our_size1 = 8;
parameter our_size2 = 16;
reg  [our_size1-1:0] A, B;          // testbench 也可以用 parameter 決定寬度
...
Adder16 m (.A(A), .B(B), .Carry_In(Carry_In), .Sum(Sum), .Carry_Out(Carry_Out));

Adder #(4) u_less (...);            // 額外補充：少對多
```
- `m`：多對多，兩個參數都被改寫。
- `u_less`：講義沒有，額外補上，示範「少對多」：只給 1 個值。
- 講義的 testbench 模組名稱是 `t`，這裡依本課程慣例改成 `Adder16_tb`。

---

## 3. 預期輸出

```
m.My_Adder16 : size1 = 8, size2 = 16
u_less       : size1 = 4, size2 = 2
t=0   A=00000111 B=00000110 Cin=1  ->  8-bit: Cout=0 Sum=00001110(14)   4-bit: Cout=0 Sum=1110
t=10  A=00000011 B=00001100 Cin=0  ->  8-bit: Cout=0 Sum=00001111(15)   4-bit: Cout=0 Sum=1111
t=20  A=00000001 B=00001111 Cin=1  ->  8-bit: Cout=0 Sum=00010001(17)   4-bit: Cout=1 Sum=0001
```

### 觀察重點
- `m` 的兩個參數都被改寫：size1 = 8、size2 = 16。
- `u_less` 只給了一個值：size1 = 4，**size2 沒給，所以保留預設的 2**。
- 8 位元的結果 `00001110`、`00001111` 和講義第 14 頁相同。

---

## 4. 試試看：多對少會怎樣？

把 `Adder16_tb.v` 的 `Adder #(4) u_less` 改成 `Adder #(4, 8, 16) u_less`（3 個值、但 Adder 只有 2 個參數）：

```
** Error (suppressible): (vsim-3006) Too many inherited module instance parameters.
Error loading design
```
- `vlog` **編譯會過**，但 `vsim` **載入模擬時出錯**，模擬跑不起來。
- 這就是講義說的「多對少不可以」。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 多個參數 | `#(值1, 值2)` 依順序對應 |
| 少對多 | 只改前面幾個，其餘保留預設值 |
| 多對少 | 不可以，vsim-3006 錯誤 |
| 依名稱 | `#(.size1(8), .size2(16))`，可以跳著改，例如只改 size2 |
| testbench 也能用 parameter | `reg [our_size1-1:0] A, B;` |
