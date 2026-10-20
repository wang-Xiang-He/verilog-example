# 03_Defparam 範例說明：用 defparam 改寫 parameter（8 位元加法器）

## 1. 這個範例在做什麼？

**Scalable Design（易於調整的設計）**（講義第 6 頁）：先寫一個寬度可以調整的加法器 `Adder`，
之後要用幾位元，就在使用的地方把寬度改掉，不用重寫電路。

要從外面改掉 `parameter` 的值，有**兩種方法**：

| 方法 | 寫法 | 範例 |
|------|------|------|
| `defparam` 敘述 | `defparam My_Adder8.size = 8;` | **本範例** |
| `#` 敘述 | `Adder #(16) My_Adder16 (...);` | [04_Param_Hash](../04_Param_Hash/Adder16_說明.md)、[05_Param_Multi](../05_Param_Multi/Adder16_說明.md) |

```
Adder8（our_size = 8）
┌──────────────────────────────────────┐
│   Adder  My_Adder8                   │
│   ┌──────────────────────┐           │
│   │ size = 1  ← 預設      │           │
│   │      ↓ defparam      │           │
│   │ size = 8             │           │
│   └──────────────────────┘           │
└──────────────────────────────────────┘
```

---

## 2. 檔案說明

| 檔案 | 用途 |
|------|------|
| `Scalable.v` | 寬度可調的加法器 `Adder`，預設 `size = 1` |
| `Adder8.v` | `` `include "Scalable.v" ``，用 `defparam` 把 size 改成 8 |
| `Adder8_tb.v` | 測試平台 |
| `run.do` | `vlog Adder8.v Adder8_tb.v`（Scalable.v 靠 `` `include `` 帶入，不列） |

### Scalable.v（講義第 6 頁）
```verilog
module Adder #(
    parameter size = 1              // 宣告一個名為 size 的 parameter，且等於 1
) (
    input  [size-1:0] A,            // A、B、Sum 都使用了 size
    input  [size-1:0] B,
    input             Carry_In,
    output [size-1:0] Sum,
    output            Carry_Out
);
    assign {Carry_Out, Sum} = A + B + Carry_In;
endmodule
```
- 所有寬度都寫成 `[size-1:0]`：`size = 1` 時是 `[0:0]`（1 位元），`size = 8` 時是 `[7:0]`。
- 講義第 6 頁的紅字：`output [size-1:0] Sum;` 和 `output [1-1:0] Sum;` 是相等的。

### Adder8.v（講義第 7 頁）
```verilog
`include "Scalable.v"       // 引用 Scalable.v，一個具有易於調整性的 Adder

module Adder8 #(
    parameter our_size = 8          // 定義為 8 個位元
) (
    input  [our_size-1:0] A,
    input  [our_size-1:0] B,
    input                 Carry_In,
    output [our_size-1:0] Sum,
    output                Carry_Out
);
    Adder My_Adder8 (A, B, Carry_In, Sum, Carry_Out);

    defparam My_Adder8.size = 8;    // 將會改寫在 My_Adder8 這個 Adder 別名中的 size 值
endmodule
```

### defparam 的語法
```
defparam 實例名稱.參數名稱 = 新的值;
```
- `My_Adder8` 是實例名稱（講義叫「別名」），`size` 是 `Adder` 裡的參數名稱。
- `defparam` 可以寫在模組裡的任何地方，不一定要緊接在實例後面。
- 講義寫死 `= 8`。如果改成 `defparam My_Adder8.size = our_size;`，以後只要改 `our_size`，裡面的 Adder 就會跟著變。

### 用 defparam 要注意
`defparam` 可以從**很遠的地方**改掉別人的參數（甚至寫成 `defparam a.b.c.size = 4;` 跨好幾層），
讀程式的人在實例那一行看不出參數被改過，容易混亂。
新的程式建議用 `#( )` 的寫法（下一個範例）；SystemVerilog 標準（IEEE 1800）已經把 `defparam` 列為未來可能淘汰的語法，不過 ModelSim 和 Quartus 目前都還支援。

---

## 3. 預期輸出

測試數值和講義第 8 頁波形相同（第 3 組是波形最右邊游標處的值）：

```
uut.our_size = 8,  uut.My_Adder8.size = 8
t=0   A=00000111(7) B=00000110(6) Cin=1    ->  Cout=0 Sum=00001110(14)
t=10  A=00000011(3) B=00001100(12) Cin=0   ->  Cout=0 Sum=00001111(15)
t=20  A=00000001(1) B=00001111(15) Cin=1   ->  Cout=0 Sum=00010001(17)
```

### 觀察重點
- 第一行用**階層式名稱** `uut.My_Adder8.size` 印出參數的值，證明 defparam 真的把 1 改成了 8。
- 前兩組結果 `00001110`、`00001111` 和講義第 8 頁相同。

---

## 4. 試試看：「修改數字觀其變化」（講義第 7 頁）

把 `Adder8.v` 的 `defparam My_Adder8.size = 8;` 改成 `= 4;` 再跑一次：

```
** Warning: (vsim-3015) [PCDPC] - Port size (4) does not match connection size (8) for port 'A'.
** Warning: (vsim-3015) [PCDPC] - Port size (4) does not match connection size (8) for port 'B'.
** Warning: (vsim-3015) [PCDPC] - Port size (4) does not match connection size (8) for port 'Sum'.
uut.our_size = 8,  uut.My_Adder8.size = 4
t=0   A=00000111(7) B=00000110(6) Cin=1    ->  Cout=0 Sum=zzzz1110(Z)
t=10  A=00000011(3) B=00001100(12) Cin=0   ->  Cout=0 Sum=zzzz1111(Z)
t=20  A=00000001(1) B=00001111(15) Cin=1   ->  Cout=1 Sum=zzzz0001(Z)
```

- 裡面的 Adder 變成 4 位元，但接在 8 位元的線上，**寬度對不起來** → ModelSim 出現警告（不是錯誤，還是會跑）。
- 只有低 4 位元被算到；`Sum` 的高 4 位元**沒有人驅動**，所以是 `z`（高阻抗）。
- t=20：1 + 15 + 1 = 17，4 位元放不下 → `Sum` 低 4 位元 = `0001`、`Cout = 1`。

> 看到 `vsim-3015` 警告一定要檢查，這通常代表參數或接線的寬度給錯了。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| Scalable Design | 寬度用 parameter 表示，使用時再決定 |
| `defparam 實例.參數 = 值;` | 從外面改寫某個實例的參數 |
| 階層式名稱 | `uut.My_Adder8.size` 可以印出參數的實際值 |
| 寬度不符 | 出現 vsim-3015 警告，沒接到的位元變 z |
| 建議 | 新程式改用 `#( )`，比 defparam 清楚 |
