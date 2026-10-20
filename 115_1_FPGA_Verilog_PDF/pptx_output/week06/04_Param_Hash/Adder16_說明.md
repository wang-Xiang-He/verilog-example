# 04_Param_Hash 範例說明：用 # 改寫 parameter（16 位元加法器）

## 1. 這個範例在做什麼？

延續 [03_Defparam](../03_Defparam/Adder8_說明.md)：同一個寬度可調的 `Adder`（預設 `size = 1`），
這次改用**第二種方法**：在實例化的時候用 **`#( )`** 直接把參數值傳進去（講義第 9 頁）。

```verilog
Adder #(our_size) My_Adder16 (A, B, Carry_In, Sum, Carry_Out);
//     ^^^^^^^^^^
//     把 our_size（16）傳給 Adder 的參數 size
```

| | defparam（03） | #（本範例） |
|---|---|---|
| 寫在哪裡 | 另外一行，可以寫在任何地方 | 直接寫在實例化那一行 |
| 看程式時 | 實例那一行看不出參數被改過 | 一眼就看到 |
| 建議 | 舊寫法，不建議 | **建議使用** |

---

## 2. 檔案說明

| 檔案 | 用途 |
|------|------|
| `Scalable.v` | 寬度可調的加法器 `Adder`，預設 `size = 1`（和 03 相同） |
| `Adder16.v` | `` `include "Scalable.v" ``，用 `#(our_size)` 把 size 改成 16 |
| `Adder16_tb.v` | 測試平台 |
| `run.do` | `vlog Adder16.v Adder16_tb.v`（Scalable.v 靠 `` `include `` 帶入，不列） |

### Adder16.v（講義第 9 頁）
```verilog
`include "Scalable.v"

module Adder16 #(
    parameter our_size = 16         // 定義為 16 個位元
) (
    input  [our_size-1:0] A,
    input  [our_size-1:0] B,
    input                 Carry_In,
    output [our_size-1:0] Sum,
    output                Carry_Out
);
    Adder #(our_size) My_Adder16 (A, B, Carry_In, Sum, Carry_Out);
endmodule
```

### 講義的問題：「如何修改數字（By order, By name）？」

`#( )` 和連接埠一樣，有**依順序**和**依名稱**兩種寫法：

| 寫法 | 例子 | 說明 |
|------|------|------|
| 依順序（by order） | `Adder #(16) My_Adder16 (...);` | 第 1 個值給第 1 個參數 |
| 依名稱（by name） | `Adder #(.size(16)) My_Adder16 (...);` | `.參數名(值)`，順序隨便 |

只有一個參數時兩種都很清楚；參數一多，依名稱比較不容易給錯（見 [05_Param_Multi](../05_Param_Multi/Adder16_說明.md)）。

### 參數可以一層一層往下傳
本範例的 testbench 再示範一次「依名稱」：

```verilog
Adder16                 uut16 (...);   // 用 Adder16 的預設 our_size = 16
Adder16 #(.our_size(4)) uut4  (...);   // 把 Adder16 的 our_size 改成 4
```

`uut4` 裡發生的事：
```
testbench：#(.our_size(4))
    ↓
Adder16：our_size = 4  →  Adder #(our_size)
    ↓
Adder：size = 4
```
改**最外層**一個數字，裡面每一層的寬度都跟著變，這就是 Scalable Design 的威力。

---

## 3. 預期輸出

16 位元的數值和講義第 10 頁波形相同：

```
uut16.My_Adder16.size = 16,  uut4.My_Adder16.size = 4
t=0   A=7 B=6 Cin=1   ->  16-bit: Cout=0 Sum=0000000000001110   4-bit: Cout=0 Sum=1110
t=10  A=3 B=12 Cin=0  ->  16-bit: Cout=0 Sum=0000000000001111   4-bit: Cout=0 Sum=1111
t=20  A=1 B=15 Cin=1  ->  16-bit: Cout=0 Sum=0000000000010001   4-bit: Cout=1 Sum=0001
```

### 觀察重點
- 第一行：`uut16` 裡的 Adder 是 16 位元，`uut4` 裡的是 4 位元，用的是**同一份程式**。
- 16 位元的 `0000000000001110`、`0000000000001111` 和講義第 10 頁相同。
- t=20：1 + 15 + 1 = 17 = `1_0001`。16 位元放得下（Cout = 0）；4 位元放不下，所以 `Sum4 = 0001`、`Cout4 = 1`。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| `模組 #(值) 實例 (...)` | 實例化時直接改寫參數 |
| 依順序 | `#(16)`：照參數宣告的順序 |
| 依名稱 | `#(.size(16))`：參數多時建議使用 |
| 一層層傳遞 | 外層的參數可以再傳給內層的參數 |
| 和 defparam 比較 | `#` 寫在實例那一行，比較清楚 |
